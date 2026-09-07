import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the account has an active subscription.
///
/// The backend is still the source of truth — this only mirrors the result of
/// a successful `/subscriptions/subscribe` call (or a restored purchase) so the
/// UI can gate premium screens without an extra round trip.
class PremiumController extends GetxController {
  static const String _keyIsPremium = 'premium_is_active';
  static const String _keyPlanName = 'premium_plan_name';
  static const String _keyPlanPrice = 'premium_plan_price';
  static const String _keyRenewsAt = 'premium_renews_at';

  final RxBool isPremium = false.obs;
  final RxString planName = ''.obs;
  final RxString planPrice = ''.obs;

  /// ISO-8601 date of the next renewal, empty when unknown.
  final RxString renewsAt = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isPremium.value = prefs.getBool(_keyIsPremium) ?? false;
    planName.value = prefs.getString(_keyPlanName) ?? '';
    planPrice.value = prefs.getString(_keyPlanPrice) ?? '';
    renewsAt.value = prefs.getString(_keyRenewsAt) ?? '';
  }

  /// Called after the backend confirms an activated subscription.
  Future<void> activate({
    required String name,
    required String price,
    DateTime? renewal,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, true);
    await prefs.setString(_keyPlanName, name);
    await prefs.setString(_keyPlanPrice, price);
    await prefs.setString(
      _keyRenewsAt,
      (renewal ?? DateTime.now().add(const Duration(days: 30)))
          .toIso8601String(),
    );

    isPremium.value = true;
    planName.value = name;
    planPrice.value = price;
    renewsAt.value = prefs.getString(_keyRenewsAt) ?? '';
  }

  /// Called after the user cancels. Access stays until [renewsAt] on the
  /// server; locally we simply flip the flag off.
  Future<void> deactivate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, false);
    isPremium.value = false;
  }

  DateTime? get renewalDate =>
      renewsAt.value.isEmpty ? null : DateTime.tryParse(renewsAt.value);
}
