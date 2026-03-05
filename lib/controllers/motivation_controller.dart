import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/models/motivation_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

class MotivationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<MotivationModel> motivations = <MotivationModel>[].obs;
  
  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  @override
  void onInit() {
    super.onInit();
    getMotivationalPhrases();
  }

  /// Fetch motivational phrases from API
  Future<void> getMotivationalPhrases({int page = 1}) async {
    try {
      isLoading(true);
      currentPage = page;

      debugPrint('=====> Fetching motivational phrases...');
      debugPrint('=====> Page: $page, Limit: $limit');

      final response = await ApiClient.getData(
        '${ApiConstants.motivationalPhrasesEndPoint.split('?')[0]}?page=$page&limit=$limit',
      );

      debugPrint('=========> Response Status: ${response.statusCode}');
      debugPrint('*********${jsonEncode(response.body)}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;
        
        if (resBody != null && resBody['status'] == 'success' && resBody['data'] != null) {
          final motivationResponse = MotivationResponseModel.fromJson(resBody);
          
          motivations.assignAll(motivationResponse.motivations);
          totalPages = motivationResponse.pagination.totalPages;
          
          debugPrint('=====> Loaded ${motivations.length} motivations');
          debugPrint('=====> Total pages: $totalPages');
        } else {
          debugPrint('❌ Invalid response format');
        }
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('❌ Error fetching motivations: $e');
      debugPrint('❌ Stack trace: $s');
    } finally {
      isLoading(false);
    }
  }

  /// Load more motivations (for pagination)
  Future<void> loadMore() async {
    if (currentPage < totalPages) {
      await getMotivationalPhrases(page: currentPage + 1);
    }
  }

  /// Refresh motivations
  Future<void> refresh() async {
    await getMotivationalPhrases(page: 1);
  }
}
