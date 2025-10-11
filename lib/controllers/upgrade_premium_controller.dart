import 'package:get/get.dart';
import 'package:limit_it_app/core/models/feature_premium-model.dart';

class UpgradePremiumController extends GetxController {
  final selectedPlan = 'monthly'.obs;

  final features = <PremiumFeature>[
    PremiumFeature(description: 'Ad-free experience.'),
    PremiumFeature(description: 'Advanced reports and statistics'),
    PremiumFeature(description: 'Detox mode'),
    PremiumFeature(description: 'PIN lock to prevent bypassing\nlimits.'),
  ].obs;

  void changePlan(String plan) {
    selectedPlan.value = plan;
  }
}
