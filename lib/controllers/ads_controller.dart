import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:limit_it_app/core/models/ad_model.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

class AdsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<AdModel> ads = <AdModel>[].obs;

  int currentPage = 1;
  int totalPages = 1;
  int limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchAds();
  }

  /// Fetch ads from API
  Future<void> fetchAds({int page = 1}) async {
    try {
      isLoading.value = true;
      currentPage = page;

      debugPrint('=====> Fetching ads...');
      debugPrint('=====> Page: $page, Limit: $limit');

      final response = await ApiClient.getData(
        '${ApiConstants.getAllAdsEndPoint.split('?')[0]}?page=$page&limit=$limit',
      );

      debugPrint('=========> Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resBody = response.body;

        if (resBody != null && resBody['status'] == 'success' && resBody['data'] != null) {
          final adsResponse = AdsResponseModel.fromJson(resBody);

          ads.assignAll(adsResponse.ads);
          totalPages = adsResponse.pagination.totalPages;

          debugPrint('=====> Loaded ${ads.length} ads');
          debugPrint('=====> Total pages: $totalPages');
        } else {
          debugPrint('❌ Invalid response format');
        }
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
      }
    } catch (e, s) {
      debugPrint('❌ Error fetching ads: $e');
      debugPrint('❌ Stack trace: $s');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more ads (for pagination)
  Future<void> loadMore() async {
    if (currentPage < totalPages) {
      await fetchAds(page: currentPage + 1);
    }
  }

  /// Refresh ads
  Future<void> refresh() async {
    await fetchAds(page: 1);
  }
}
