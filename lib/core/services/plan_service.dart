import 'package:flutter/material.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';
import 'package:limit_it_app/core/helpers/localization_helper.dart';

class PlanService {
  /// Fetch all plans
  static Future<List<PlanModel>> getAllPlans() async {
    try {
      debugPrint('====> Fetching plans from API: ${ApiConstants.getPlansEndPoint}');

      final response = await ApiClient.getData(ApiConstants.getPlansEndPoint);

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;

        if (data is Map<String, dynamic>) {
          final status = data['status'];
          final statusCode = data['statusCode'];

          if (status == 'success' && statusCode == 200) {
            final plansData = data['data'] as List;

            final plans = plansData
                .map((planJson) => PlanModel.fromJson(planJson))
                .toList();

            debugPrint('====> Successfully fetched ${plans.length} plans');
            return plans;
          } else {
            debugPrint('====> API returned error: $status, $statusCode');
            throw Exception(data['message'] ?? appL10n.failedToFetchPlans);
          }
        } else {
          debugPrint('====> Unexpected response format: $data');
          throw Exception(appL10n.invalidResponseFormat);
        }
      } else {
        debugPrint('====> API error: ${response.statusCode}');
        throw Exception(appL10n.failedToFetchPlansWithError('${response.statusText}'));
      }
    } catch (e) {
      debugPrint('====> Error in getAllPlans: $e');
      rethrow;
    }
  }

  static Future<PlanModel?> getPlanById(String planId) async {
    try {
      final plans = await getAllPlans();
      return plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      debugPrint('====> Error getting plan by ID: $e');
      return null;
    }
  }

  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static String getPlanDurationText(int duration) {
    if (duration == 30) {
      return 'Monthly';
    } else if (duration >= 365) {
      return 'Yearly';
    } else {
      return '$duration days';
    }
  }
}
