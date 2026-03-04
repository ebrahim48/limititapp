import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:limit_it_app/core/services/api_client.dart';
import 'package:limit_it_app/core/services/api_constants.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  //=====================> About Us <=====================
  final RxBool isLoadingAboutUs = false.obs;
  final RxBool hasErrorAboutUs = false.obs;
  final RxString aboutUsContent = ''.obs;
  final RxString aboutUsName = ''.obs;
  final RxString aboutUsEmail = ''.obs;
  final RxString aboutUsPhone = ''.obs;

  //=====================> Privacy Policy <=====================
  final RxBool isLoadingPrivacyPolicy = false.obs;
  final RxBool hasErrorPrivacyPolicy = false.obs;
  final RxString privacyPolicyContent = ''.obs;

  //=====================> Terms & Conditions <=====================
  final RxBool isLoadingTerms = false.obs;
  final RxBool hasErrorTerms = false.obs;
  final RxString termsContent = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('SettingsController initialized');
  }

  //=====================> Fetch About Us <=====================
  Future<void> fetchAboutUs() async {
    try {
      isLoadingAboutUs.value = true;
      hasErrorAboutUs.value = false;

      final response = await ApiClient.getData(ApiConstants.aboutUsPoint);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['status'] == 'success' && data['data'] != null) {
          aboutUsContent.value = _stripHtmlTags(data['data']['content'] ?? '');
          aboutUsName.value = data['data']['name'] ?? '';
          aboutUsEmail.value = data['data']['email'] ?? '';
          aboutUsPhone.value = data['data']['phone'] ?? '';
          
          debugPrint('About Us loaded successfully');
        } else {
          hasErrorAboutUs.value = true;
          debugPrint('About Us: Invalid response format');
        }
      } else {
        hasErrorAboutUs.value = true;
        debugPrint('About Us: API error - ${response.statusCode}');
      }
    } catch (e) {
      hasErrorAboutUs.value = true;
      debugPrint('About Us error: $e');
    } finally {
      isLoadingAboutUs.value = false;
    }
  }

  //=====================> Fetch Privacy Policy <=====================
  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoadingPrivacyPolicy.value = true;
      hasErrorPrivacyPolicy.value = false;

      final response = await ApiClient.getData(ApiConstants.privacyPolicyPoint);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['status'] == 'success' && data['data'] != null) {
          privacyPolicyContent.value = _stripHtmlTags(data['data']['content'] ?? '');
          debugPrint('Privacy Policy loaded successfully');
        } else {
          hasErrorPrivacyPolicy.value = true;
          debugPrint('Privacy Policy: Invalid response format');
        }
      } else {
        hasErrorPrivacyPolicy.value = true;
        debugPrint('Privacy Policy: API error - ${response.statusCode}');
      }
    } catch (e) {
      hasErrorPrivacyPolicy.value = true;
      debugPrint('Privacy Policy error: $e');
    } finally {
      isLoadingPrivacyPolicy.value = false;
    }
  }

  //=====================> Fetch Terms & Conditions <=====================
  Future<void> fetchTermsAndConditions() async {
    try {
      isLoadingTerms.value = true;
      hasErrorTerms.value = false;

      final response = await ApiClient.getData(ApiConstants.termsConditionPoint);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['status'] == 'success' && data['data'] != null) {
          termsContent.value = _stripHtmlTags(data['data']['content'] ?? '');
          debugPrint('Terms & Conditions loaded successfully');
        } else {
          hasErrorTerms.value = true;
          debugPrint('Terms & Conditions: Invalid response format');
        }
      } else {
        hasErrorTerms.value = true;
        debugPrint('Terms & Conditions: API error - ${response.statusCode}');
      }
    } catch (e) {
      hasErrorTerms.value = true;
      debugPrint('Terms & Conditions error: $e');
    } finally {
      isLoadingTerms.value = false;
    }
  }

  //=====================> HTML to Plain Text Converter <=====================
  String _stripHtmlTags(String html) {
    if (html.isEmpty) return '';

    String text = html;

    // Add newlines for block elements before removing tags
    text = text.replaceAll(RegExp(r'<h1[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'</h1>'), '\n\n');
    text = text.replaceAll(RegExp(r'<h2[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'</h2>'), '\n\n');
    text = text.replaceAll(RegExp(r'<h3[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'</h3>'), '\n\n');
    text = text.replaceAll(RegExp(r'<h4[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'</h4>'), '\n\n');
    text = text.replaceAll(RegExp(r'<p[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</p>'), '\n\n');
    text = text.replaceAll(RegExp(r'<br[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'<br/>'), '\n');
    text = text.replaceAll(RegExp(r'<br />'), '\n');
    text = text.replaceAll(RegExp(r'<li[^>]*>'), '• ');
    text = text.replaceAll(RegExp(r'</li>'), '\n');
    text = text.replaceAll(RegExp(r'<ul[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</ul>'), '\n');
    text = text.replaceAll(RegExp(r'<ol[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</ol>'), '\n');
    text = text.replaceAll(RegExp(r'<div[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'</div>'), '\n');
    text = text.replaceAll(RegExp(r'<span[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</span>'), '');
    text = text.replaceAll(RegExp(r'<strong[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</strong>'), '');
    text = text.replaceAll(RegExp(r'<b[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</b>'), '');
    text = text.replaceAll(RegExp(r'<em[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</em>'), '');
    text = text.replaceAll(RegExp(r'<i[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</i>'), '');
    text = text.replaceAll(RegExp(r'<u[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</u>'), '');
    text = text.replaceAll(RegExp(r'<a[^>]*>'), '');
    text = text.replaceAll(RegExp(r'</a>'), '');

    // Remove all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');

    // Decode HTML entities
    text = text.replaceAll(RegExp(r'&nbsp;'), ' ');
    text = text.replaceAll(RegExp(r'&amp;'), '&');
    text = text.replaceAll(RegExp(r'&lt;'), '<');
    text = text.replaceAll(RegExp(r'&gt;'), '>');
    text = text.replaceAll(RegExp(r'&quot;'), '"');
    text = text.replaceAll(RegExp(r'&#39;'), "'");
    text = text.replaceAll(RegExp(r'&apos;'), "'");
    text = text.replaceAll(RegExp(r'&mdash;'), '—');
    text = text.replaceAll(RegExp(r'&ndash;'), '–');
    text = text.replaceAll(RegExp(r'&hellip;'), '…');
    text = text.replaceAll(RegExp(r'&lsquo;'), ''');
    text = text.replaceAll(RegExp(r'&rsquo;'), ''');
    text = text.replaceAll(RegExp(r'&ldquo;'), '"');
    text = text.replaceAll(RegExp(r'&rdquo;'), '"');

    // Remove multiple newlines and trim
    text = text.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    text = text.replaceAll(RegExp(r' +'), ' ');
    text = text.trim();

    return text;
  }

  //=====================> Reset Methods <=====================
  void resetAboutUs() {
    isLoadingAboutUs.value = false;
    hasErrorAboutUs.value = false;
    aboutUsContent.value = '';
    aboutUsName.value = '';
    aboutUsEmail.value = '';
    aboutUsPhone.value = '';
  }

  void resetPrivacyPolicy() {
    isLoadingPrivacyPolicy.value = false;
    hasErrorPrivacyPolicy.value = false;
    privacyPolicyContent.value = '';
  }

  void resetTerms() {
    isLoadingTerms.value = false;
    hasErrorTerms.value = false;
    termsContent.value = '';
  }
}
