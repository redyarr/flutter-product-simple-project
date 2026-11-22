import 'dart:async' as async;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_testapp/core/constants/api_constants.dart';
import 'package:flutter_testapp/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<Map<String, Object?>> getJson(Uri uri) async {
    if (uri.scheme != 'https') {
      throw const NetworkException('Only HTTPS requests are permitted.');
    }

    try {
      final http.Response response = await _httpClient.get(
        uri,
        headers: const <String, String>{
          'Accept': 'application/json',
        },
      ).timeout(ApiConstants.timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ServerException(
          statusCode: response.statusCode,
          message: 'HTTP ${response.statusCode}',
        );
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<Object?, Object?>) {
        throw const DataParsingException('Expected root JSON object.');
      }

      final Map<String, Object?> typedMap = <String, Object?>{};
      for (final MapEntry<Object?, Object?> entry in decoded.entries) {
        final Object? key = entry.key;
        if (key is String) {
          typedMap[key] = entry.value;
        }
      }
      return typedMap;
    } on async.TimeoutException catch (error) {
      _logDebug('Request timeout for ${uri.host}${uri.path}: $error');
      throw const TimeoutException('Request exceeded 10-second timeout.');
    } on ServerException {
      rethrow;
    } on DataParsingException {
      rethrow;
    } on FormatException catch (error) {
      _logDebug('JSON format error for ${uri.host}${uri.path}: $error');
      throw const DataParsingException('Invalid JSON payload.');
    } on http.ClientException catch (error) {
      _logDebug('HTTP client error for ${uri.host}${uri.path}: $error');
      throw const NetworkException('HTTP transport failure.');
    } on Object catch (error) {
      _logDebug('Unexpected network error for ${uri.host}${uri.path}: $error');
      throw const NetworkException('Unexpected transport failure.');
    }
  }

  void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[ApiClient] $message');
    }
  }

  void close() {
    _httpClient.close();
  }
}
