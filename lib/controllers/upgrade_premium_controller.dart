import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

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

  /// Build endpoint with query parameters
  String getPlansWithQueryEndPoint({String? type, bool? isActive}) {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) {
      queryParams['type'] = type;
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }
    
    if (queryParams.isEmpty) {
      return ApiConstants.getPlansEndPoint;
    }
    
    final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '${ApiConstants.getPlansEndPoint}?$queryString';
  }

  Future<void> fetchPlans() async {
    try {
      isLoading.value = true;
      isError.value = false;
      
      // Build endpoint with query parameters
      final endpoint = getPlansWithQueryEndPoint(
        type: planType.value.isEmpty ? null : planType.value,
        isActive: filterActive.value,
      );
      
      debugPrint('====> Fetching plans: $endpoint');
      
      final response = await ApiClient.getData(endpoint);
      
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        
        if (data is Map<String, dynamic>) {
          final status = data['status'];
          final statusCode = data['statusCode'];
          
          if (status == 'success' && statusCode == 200) {
            final plansData = data['data'] as List;
            final fetchedPlans = plansData.map((planJson) => PlanModel.fromJson(planJson)).toList();
            
            if (fetchedPlans.isNotEmpty) {
              plans.assignAll(fetchedPlans);
              selectedPlan.value = plans.first.id;
            } else {
              isError.value = true;
              errorMessage.value = appL10n.noPlansAvailable;
            }
          } else {
            isError.value = true;
            errorMessage.value = data['message'] ?? appL10n.failedToFetchPlans;
          }
        } else {
          isError.value = true;
          errorMessage.value = appL10n.invalidResponseFormat;
        }
      } else {
        isError.value = true;
        errorMessage.value = appL10n.failedToFetchPlansWithError('${response.statusText}');
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
