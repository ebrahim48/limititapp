import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

/// Result returned after a successful social login.
class SocialLoginResult {
  final Map<String, dynamic> user;
  final String accessToken;
  final String refreshToken;

  const SocialLoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

/// Handles Google and Apple sign-in via Firebase Auth,
/// then exchanges the Firebase ID token for a LimitIT JWT pair.
class SocialAuthService {
  SocialAuthService._();
  static final SocialAuthService instance = SocialAuthService._();

  // Resolved lazily: main() tolerates a failed Firebase.initializeApp() (e.g.
  // missing GoogleService-Info.plist), and FirebaseAuth.instance throws then.
  FirebaseAuth get _firebaseAuth {
    if (Firebase.apps.isEmpty) {
      throw Exception(
        'Firebase is not configured on this device. Social login is unavailable.',
      );
    }
    return FirebaseAuth.instance;
  }

  // Web client ID from google-services.json (type 3 = web client).
  // This is required by GoogleSignIn on Android to return a server-auth code
  // and to get an idToken that the backend can verify with firebase-admin.
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '499698578290-44brc5ch03s9gqd4pss9c5goji31d42r.apps.googleusercontent.com',
  );

  // ---------------------------------------------------------------------------
  // Google Sign-In
  // ---------------------------------------------------------------------------

  /// Signs in the user with Google, authenticates with Firebase, then calls
  /// the LimitIT `/users/social-login` endpoint to get the app JWT tokens.
  ///
  /// Throws an exception with a user-readable message on any failure.
  Future<SocialLoginResult> signInWithGoogle() async {
    // 1. Trigger the Google account picker.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled.');
    }

    // 2. Fetch auth details from the chosen account.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3. Build an OAuth credential for Firebase.
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to Firebase with the Google credential.
    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase sign-in returned no user.');
    }

    // 5. Get a fresh Firebase ID token (the one the backend verifies).
    final String? idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase ID token.');
    }

    debugPrint('✅ Firebase Google sign-in succeeded for: ${firebaseUser.email}');

    // 6. Exchange the Firebase ID token for a LimitIT JWT pair.
    return _exchangeWithBackend(
      idToken: idToken,
      displayName: firebaseUser.displayName,
    );
  }

  // ---------------------------------------------------------------------------
  // Apple Sign-In
  // ---------------------------------------------------------------------------

  /// Signs in the user with Apple, authenticates with Firebase, then calls
  /// the LimitIT `/users/social-login` endpoint to get the app JWT tokens.
  ///
  /// Apple only returns the user's name on the very first authorization, so
  /// it is forwarded to the backend whenever present.
  Future<SocialLoginResult> signInWithApple() async {
    // Android has no native Apple sheet; Firebase runs Apple's web flow
    // through the Services ID configured in the Firebase console.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _signInWithAppleWeb();
    }

    // 1. Firebase requires a nonce: Apple gets the SHA-256 hash, Firebase the raw value.
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    // 2. Trigger the Apple sign-in sheet.
    final AuthorizationCredentialAppleID appleCredential;
    try {
      appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception('Apple sign-in was cancelled.');
      }
      rethrow;
    }

    final fullName = [appleCredential.givenName, appleCredential.familyName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');

    // No GoogleService-Info.plist yet: skip Firebase and hand the backend
    // Apple's own identity token.
    if (Firebase.apps.isEmpty) {
      final appleIdToken = appleCredential.identityToken;
      if (appleIdToken == null) {
        throw Exception('Apple returned no identity token.');
      }
      debugPrint('⚠️ Firebase not configured — sending Apple identity token to backend');
      return _exchangeWithBackend(
        idToken: appleIdToken,
        displayName: fullName,
        email: appleCredential.email,
      );
    }

    // 3. Build an OAuth credential for Firebase and sign in.
    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    final UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase sign-in returned no user.');
    }

    // 4. Get a fresh Firebase ID token (the one the backend verifies).
    final String? idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase ID token.');
    }

    debugPrint('✅ Firebase Apple sign-in succeeded for: ${firebaseUser.email}');

    // 5. Exchange the Firebase ID token for a LimitIT JWT pair.
    return _exchangeWithBackend(
      idToken: idToken,
      displayName: fullName.isNotEmpty ? fullName : firebaseUser.displayName,
      email: appleCredential.email ?? firebaseUser.email,
    );
  }

  /// Apple sign-in through Firebase's hosted web flow (used on Android).
  Future<SocialLoginResult> _signInWithAppleWeb() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');

    final UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'canceled' || e.code == 'web-context-canceled') {
        throw Exception('Apple sign-in was cancelled.');
      }
      rethrow;
    }

    final User? firebaseUser = userCredential.user;
    if (firebaseUser == null) {
      throw Exception('Firebase sign-in returned no user.');
    }

    final String? idToken = await firebaseUser.getIdToken();
    if (idToken == null) {
      throw Exception('Failed to retrieve Firebase ID token.');
    }

    debugPrint('✅ Firebase Apple (web) sign-in succeeded for: ${firebaseUser.email}');

    return _exchangeWithBackend(
      idToken: idToken,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Sign out from both Firebase and Google (clears cached account).
  Future<void> signOut() async {
    await Future.wait([
      if (Firebase.apps.isNotEmpty) FirebaseAuth.instance.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ---------------------------------------------------------------------------
  // Backend exchange
  // ---------------------------------------------------------------------------

  /// POSTs the Firebase [idToken] to `POST /users/social-login` and returns
  /// the LimitIT access/refresh tokens plus user data.
  Future<SocialLoginResult> _exchangeWithBackend({
    required String idToken,
    String? displayName,
    String? email,
  }) async {
    final body = <String, dynamic>{'idToken': idToken};
    if (displayName != null && displayName.isNotEmpty) {
      body['name'] = displayName;
    }
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    final response = await ApiClient.postData(
      ApiConstants.socialLoginEndPoint,
      jsonEncode(body),
    );

    debugPrint(
      '🔄 Social-login backend status: ${response.statusCode}\n'
      '🔄 Social-login backend body: ${response.body}',
    );

    // ApiClient.handleResponse() already decoded JSON into response.body.
    // Treat any 2xx as success.
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      final res = response.body;

      // Validate the response shape before casting.
      if (res is Map) {
        final status = res['status']?.toString();
        final token = res['token']?.toString();
        final refreshToken = res['refreshToken']?.toString();
        final data = res['data'];

        if (status == 'success' &&
            token != null &&
            token.isNotEmpty &&
            refreshToken != null &&
            refreshToken.isNotEmpty &&
            data is Map) {
          return SocialLoginResult(
            user: Map<String, dynamic>.from(data),
            accessToken: token,
            refreshToken: refreshToken,
          );
        }

        // Backend returned 2xx but with a failure status in the body.
        final msg = res['message']?.toString() ?? 'Social login failed.';
        throw Exception(msg);
      }
    }

    // Non-2xx: extract the server's error message if available.
    String errorMessage = 'Social login failed (status $statusCode)';
    try {
      final errBody = response.body;
      if (errBody is Map && errBody['message'] != null) {
        errorMessage = errBody['message'].toString();
      }
    } catch (_) {}

    throw Exception(errorMessage);
  }
}
