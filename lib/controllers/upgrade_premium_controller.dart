import 'package:get/get.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/services/plan_service.dart';

class UpgradePremiumController extends GetxController {
  final selectedPlan = ''.obs;
  final plans = <PlanModel>[].obs;
  final isLoading = true.obs;
  final isError = false.obs;
  final errorMessage = ''.obs;
  
  // Query parameters for filtering
  final planType = ''.obs; // 'monthly', 'yearly', or '' for all
  final filterActive = true.obs; // Filter by isActive status

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      isError.value = false;
      
      // Pass query parameters to filter plans
      final fetchedPlans = await PlanService.getAllPlans(
        type: planType.value.isEmpty ? null : planType.value,
        isActive: filterActive.value,
      );
      
      if (fetchedPlans.isNotEmpty) {
        plans.assignAll(fetchedPlans);
        // Select first plan by default
        if (plans.isNotEmpty) {
          selectedPlan.value = plans.first.id;
        }
      } else {
        isError.value = true;
        errorMessage.value = 'No plans available';
      }
    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void changePlan(String planId) {
    selectedPlan.value = planId;
  }

  PlanModel? getSelectedPlan() {
    try {
      return plans.firstWhere((plan) => plan.id == selectedPlan.value);
    } catch (e) {
      return null;
    }
  }
  
  /// Update plan type filter and refetch
  void setPlanTypeFilter(String type) {
    planType.value = type;
    fetchPlans();
  }
  
  /// Update isActive filter and refetch
  void setActiveFilter(bool isActive) {
    filterActive.value = isActive;
    fetchPlans();
  }
}
