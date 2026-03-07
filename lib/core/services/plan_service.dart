import 'package:flutter/material.dart';
import 'package:limit_it_app/core/models/plan_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

class PlanService {
  /// Fetch all plans with optional query parameters
  /// [type] - Filter by plan type (e.g., 'monthly', 'yearly')
  /// [isActive] - Filter by active status (true/false)
  static Future<List<PlanModel>> getAllPlans({String? type, bool? isActive}) async {
    try {
      final endpoint = ApiConstants.getPlansWithQueryEndPoint(type: type, isActive: isActive);
      debugPrint('====> Fetching plans from API: $endpoint');
      
      final response = await ApiClient.getData(endpoint);
      
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
            throw Exception(data['message'] ?? 'Failed to fetch plans');
          }
        } else {
          debugPrint('====> Unexpected response format: $data');
          throw Exception('Invalid response format');
        }
      } else {
        debugPrint('====> API error: ${response.statusCode}');
        throw Exception('Failed to fetch plans: ${response.statusText}');
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
