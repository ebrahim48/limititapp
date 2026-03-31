import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:limit_it_app/core/app_constants/app_constants.dart';
import 'package:limit_it_app/core/helpers/prefs_helper.dart';
import 'package:mime/mime.dart';
import 'api_constants.dart';
import 'error_response.dart';


class ApiClient extends GetxService {
  static var client = http.Client();
  static const String noInternetMessage = "Can't connect to the internet!";
  static const int timeoutInSeconds = 60; // Increased from 20s to 60s for better reliability
  static const int maxRetries = 2; // Retry failed requests up to 2 times
  static String bearerToken = "";

//==========================================> Get Data <======================================
  static Future<Response> getData(String uri,
      {Map<String, dynamic>? query, Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

    var mainHeaders = {
      'Content-Type': 'application/json',
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri');
      debugPrint('====> Full URL: ${ApiConstants.baseUrl + uri}');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> Token from prefs: ${bearerToken.isEmpty ? "EMPTY" : "${bearerToken.substring(0, bearerToken.length.clamp(0, 20))}..."}');

      http.Response response = await client
          .get(
        Uri.parse(ApiConstants.baseUrl + uri),
        headers: headers ?? mainHeaders,
      ).timeout(Duration(seconds: timeoutInSeconds));

      debugPrint('====> Response Status: ${response.statusCode}');
      debugPrint('====> Response Body: ${response.body}');

      return handleResponse(response, uri);
    } on SocketException catch (e) {
      debugPrint('------------SocketException: ${e.toString()}');
      debugPrint('------------Check internet permission and connectivity');
      return const Response(statusCode: 1, statusText: "No internet connection");
    } on HttpException catch (e) {
      debugPrint('------------HttpException: ${e.toString()}');
      return const Response(statusCode: 1, statusText: "Server error");
    } on TimeoutException catch (e) {
      debugPrint('------------TimeoutException: ${e.toString()}');
      return const Response(statusCode: 1, statusText: "Request timeout. Please try again.");
    } catch (e) {
      debugPrint('------------Exception: ${e.toString()}');
      return const Response(statusCode: 1, statusText: "Can't connect to the internet!");
    }
  }

//==========================================> Post Data <======================================
  static Future<Response> postData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    String bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

    var mainHeaders = {
      'Content-Type': 'application/json',
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken'
    };

    try {
      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: $mainHeaders');
      debugPrint('====> API Body: $body');
      debugPrint('====> Bearer Token: ${bearerToken.isEmpty ? "NOT SET" : "${bearerToken.substring(0, bearerToken.length.clamp(0, 20))}..."}');

      http.Response response = await _postWithRetry(
        Uri.parse(ApiConstants.baseUrl + uri),
        body,
        headers ?? mainHeaders,
      );

      debugPrint("==========> Response Post Method : ${response.statusCode} \n*********${response.body}");
      return handleResponse(response, uri);
    } on TimeoutException catch (e) {
      debugPrint("===> TimeoutException in postData: $e");
      debugPrint("===> Request timed out after $timeoutInSeconds seconds");
      return const Response(statusCode: 1, statusText: "Request timed out. Please try again.");
    } on SocketException catch (e) {
      debugPrint("===> SocketException in postData: $e");
      return const Response(statusCode: 1, statusText: "No internet connection");
    } catch (e, s) {
      debugPrint("===> Error in postData: e$e");
      debugPrint("===> Error in postData: s$s");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  /// Helper method to POST with retry logic
  static Future<http.Response> _postWithRetry(
    Uri uri,
    dynamic body,
    Map<String, String> headers,
  ) async {
    http.Response? lastResponse;
    Object? lastException;

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        if (attempt > 0) {
          debugPrint('===> Retry attempt ${attempt}/$maxRetries for $uri');
          // Add delay before retry (exponential backoff)
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }

        lastResponse = await client.post(
          uri,
          body: body,
          headers: headers,
        ).timeout(Duration(seconds: timeoutInSeconds));

        // If successful, return immediately
        return lastResponse;
      } on TimeoutException catch (e) {
        lastException = e;
        debugPrint('===> Timeout attempt ${attempt + 1}/$maxRetries: $e');
        if (attempt == maxRetries) rethrow;
      } on SocketException catch (e) {
        lastException = e;
        debugPrint('===> SocketException attempt ${attempt + 1}/$maxRetries: $e');
        if (attempt == maxRetries) rethrow;
      } catch (e) {
        lastException = e;
        debugPrint('===> Exception attempt ${attempt + 1}/$maxRetries: $e');
        if (attempt == maxRetries) rethrow;
      }
    }

    // This should never be reached due to rethrow, but added for safety
    throw lastException ?? Exception('Unknown error');
  }




  //==========================================> patch<======================================
  static Future<Response> patch(
      String uri,
      var body,
      {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

    var mainHeaders = {
      'Content-Type': 'application/json',
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await client
          .patch(
        Uri.parse(ApiConstants.baseUrl + uri),
        body: body,
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      debugPrint(
          "==========> Response Post Method :------ : ${response.statusCode}");
      return handleResponse(response, uri);
    } catch (e, s) {
      debugPrint("===> $e");
      debugPrint("===> $s");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }




  static Future<Response> postMultipartData(
      String uri,
      Map<String, String> body, {
        required List<MultipartBody> multipartBody,
        Map<String, String>? headers,
      }) async {
    try {
      bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

      var mainHeaders = {
        if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
      };

      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody.length} files');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConstants.baseUrl + uri),
      );

      request.headers.addAll(headers ?? mainHeaders);

      for (MultipartBody element in multipartBody) {
        final mimeType = lookupMimeType(element.file.path) ?? 'application/octet-stream';
        final mimeSplit = mimeType.split('/');

        request.files.add(
          await http.MultipartFile.fromPath(
            element.key,
            element.file.path,
            contentType: MediaType(mimeSplit[0], mimeSplit[1]),
          ),
        );
      }

      request.fields.addAll(body);

      http.Response _response =
      await http.Response.fromStream(await request.send());
      return handleResponse(_response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }


  // static Future<Response> postMultipartData(
  //     String uri, Map<String, String> body,
  //     {required List<MultipartBody> multipartBody,
  //       Map<String, String>? headers}) async {
  //   try {
  //     bearerToken = await PrefsHelper.getString(AppConstants.bearerToken);
  //
  //     var mainHeaders = {
  //       'Content-Type': 'multipart/form-data',
  //       'Authorization': bearerToken
  //     };
  //
  //     debugPrint('====> API Call: $uri\nHeader: ${headers ?? mainHeaders}');
  //     debugPrint('====> API Body: $body with ${multipartBody.length} picture');
  //     var request =
  //     http.MultipartRequest('POST', Uri.parse(ApiConstants.baseUrl + uri));
  //     request.headers.addAll(headers ?? mainHeaders);
  //     for (MultipartBody element in multipartBody) {
  //       request.files.add(await http.MultipartFile.fromPath(
  //         element.key,
  //         element.file.path,
  //       ));
  //     }
  //     request.fields.addAll(body);
  //     http.Response _response =
  //     await http.Response.fromStream(await request.send());
  //     return handleResponse(_response, uri);
  //   } catch (e) {
  //     return const Response(statusCode: 1, statusText: noInternetMessage);
  //   }
  // }


  ///=======================Patch By Id========================>
  static Future<Response> patchData(
      String url, {
        Map<String, dynamic>? body,
      }) async {
    bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';
    
    final headers = {
      'Content-Type': 'application/json',
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
    };

    final response = await http.patch(
      Uri.parse(ApiConstants.baseUrl + url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return handleResponse(response, url);
  }






//==========================================> Put Data <======================================
  static Future<Response> putData(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

    var mainHeaders = {
      'Content-Type': 'application/json',
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await http
          .put(
        Uri.parse(ApiConstants.baseUrl + uri),
        body: jsonEncode(body),
        headers: headers ?? mainHeaders,
      )
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Put Multipart Data <======================================
  static Future<Response> putMultipartData(String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
        List<MultipartListBody>? multipartListBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

      var mainHeaders = {
        if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
      };

      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');

      var request =
      http.MultipartRequest('PUT', Uri.parse(ApiConstants.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");
          String? mimeType = lookupMimeType(element.file.path);
          request.files.add(http.MultipartFile(
            element.key,
            element.file.readAsBytes().asStream(),
            element.file.lengthSync(),
            contentType: MediaType.parse(mimeType!),
          ));
        });
      }
      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: noInternetMessage,
          body: json.decode(content));
    } catch (e) {
      debugPrint("====================================e $e");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Patch Multipart Data <======================================
  static Future<Response> patchMultipartData(
      String uri, Map<String, String> body,
      {List<MultipartBody>? multipartBody,
        List<MultipartListBody>? multipartListBody,
        Map<String, String>? headers}) async {
    try {
      bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';
      // bearerToken = PrefsHelper.token;

      var mainHeaders = {
        if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
      };

      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body with ${multipartBody?.length} picture');
      var request =
      http.MultipartRequest('PATCH', Uri.parse(ApiConstants.baseUrl + uri));
      request.fields.addAll(body);

      if (multipartBody!.isNotEmpty) {
        multipartBody.forEach((element) async {
          debugPrint("path : ${element.file.path}");
          String? mimeType = lookupMimeType(element.file.path);
          request.files.add(http.MultipartFile(
            element.key,
            element.file.readAsBytes().asStream(),
            element.file.lengthSync(),
            filename: element.file.path.split('/').last,
            contentType: MediaType.parse(mimeType!),
          ));
        });
      }
      request.headers.addAll(mainHeaders);
      http.StreamedResponse response = await request.send();
      final content = await response.stream.bytesToString();
      debugPrint(
          '====> API Response: [${response.statusCode}}] $uri\n$content');

      return Response(
          statusCode: response.statusCode,
          statusText: noInternetMessage,
          body: json.decode(content));
    } catch (e) {
      debugPrint("====================================e $e");
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Delete Data <======================================
  static Future<Response> deleteData(String uri,
      {Map<String, String>? headers, dynamic body}) async {
    bearerToken = await PrefsHelper.getStringNullable(AppConstants.bearerToken) ?? '';

    var mainHeaders = {
      'Content-Type': 'application/json',
      if (bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken'
    };
    try {
      debugPrint('====> API Call: $uri');
      debugPrint('====> Header: ${headers ?? mainHeaders}');
      debugPrint('====> API Body: $body');

      http.Response response = await http
          .delete(Uri.parse(ApiConstants.baseUrl + uri),
          headers: headers ?? mainHeaders, body: body)
          .timeout(const Duration(seconds: timeoutInSeconds));
      return handleResponse(response, uri);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  //==========================================> Handle Response <======================================
  static Response handleResponse(http.Response response, String uri) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {
      debugPrint(e.toString());
    }
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if (response0.statusCode != 200 &&
        response0.body != null &&
        response0.body is! String) {
      ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
      response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.message);
    } else if (response0.statusCode != 200 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }

    debugPrint('====> API Response: [${response0.statusCode}] $uri\n${response0.body}');
    return response0;
  }
}

class MultipartBody {
  String key;
  File file;

  MultipartBody(this.key, this.file);
}

class MultipartListBody {
  String key;
  String value;
  MultipartListBody(this.key, this.value);
}