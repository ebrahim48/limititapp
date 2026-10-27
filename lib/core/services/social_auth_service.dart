import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  /// iOS needs GoogleService-Info.plist (plus its REVERSED_CLIENT_ID URL
  /// scheme in Info.plist) for the Google sheet — without them the plugin
  /// crashes, so the button stays hidden until that config ships.
  bool get isGoogleSignInAvailable =>
      defaultTargetPlatform != TargetPlatform.iOS || Firebase.apps.isNotEmpty;

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
  /// Uses Firebase's own Apple provider: native sheet on iOS/macOS, hosted
  /// web flow on Android. Building the credential manually from
  /// sign_in_with_apple failed with "Invalid OAuth response from apple.com".
  Future<SocialLoginResult> signInWithApple() async {
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

    debugPrint('✅ Firebase Apple sign-in succeeded for: ${firebaseUser.email}');

    return _exchangeWithBackend(
      idToken: idToken,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
    );
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
