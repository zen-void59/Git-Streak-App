import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final bool isRateLimit;

  ApiException({
    this.statusCode,
    required this.message,
    this.isRateLimit = false,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(milliseconds: 500);
  static const Duration timeout = Duration(seconds: 15);

  Map<String, String> _headers = {};

  void setHeaders(Map<String, String> headers) {
    _headers = headers;
  }

  /// Makes an HTTP GET request with retry logic and exponential backoff.
  ///
  /// Retries on:
  /// - Network errors (SocketException, TimeoutException)
  /// - Server errors (5xx status codes)
  /// - Rate limiting (429 status code)
  ///
  /// Does NOT retry on:
  /// - Client errors (4xx except 429)
  /// - Successful responses (2xx)
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration? timeoutDuration,
  }) async {
    final effectiveHeaders = {..._headers, ...?headers};
    final effectiveTimeout = timeoutDuration ?? timeout;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http
            .get(url, headers: effectiveHeaders)
            .timeout(effectiveTimeout);

        // Success - return immediately
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        // Rate limiting - retry with backoff
        if (response.statusCode == 429) {
          debugPrint('Rate limited. Attempt ${attempt + 1}/$maxRetries');
          if (attempt < maxRetries - 1) {
            await _delay(attempt);
            continue;
          }
        }

        // Other client errors - don't retry
        if (response.statusCode >= 400 && response.statusCode < 500) {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Client error: ${response.statusCode}',
          );
        }

        // Server errors - retry
        if (response.statusCode >= 500) {
          debugPrint('Server error ${response.statusCode}. Attempt ${attempt + 1}/$maxRetries');
          if (attempt < maxRetries - 1) {
            await _delay(attempt);
            continue;
          }
        }

        // Final attempt failed
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Request failed after ${attempt + 1} attempts',
        );
      } on SocketException catch (e) {
        debugPrint('Network error: ${e.message}. Attempt ${attempt + 1}/$maxRetries');
        if (attempt < maxRetries - 1) {
          await _delay(attempt);
          continue;
        }
        throw ApiException(message: 'No internet connection');
      } on TimeoutException {
        debugPrint('Timeout. Attempt ${attempt + 1}/$maxRetries');
        if (attempt < maxRetries - 1) {
          await _delay(attempt);
          continue;
        }
        throw ApiException(message: 'Request timed out');
      } on ApiException {
        rethrow;
      } catch (e) {
        debugPrint('Unexpected error: $e');
        throw ApiException(message: 'Unexpected error: $e');
      }
    }

    throw ApiException(message: 'Request failed after $maxRetries attempts');
  }

  /// Makes an HTTP POST request with retry logic
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeoutDuration,
  }) async {
    final effectiveHeaders = {..._headers, ...?headers};
    final effectiveTimeout = timeoutDuration ?? timeout;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http
            .post(url, headers: effectiveHeaders, body: body)
            .timeout(effectiveTimeout);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        if (response.statusCode == 429) {
          if (attempt < maxRetries - 1) {
            await _delay(attempt);
            continue;
          }
        }

        if (response.statusCode >= 400 && response.statusCode < 500) {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Client error: ${response.statusCode}',
          );
        }

        if (response.statusCode >= 500) {
          if (attempt < maxRetries - 1) {
            await _delay(attempt);
            continue;
          }
        }

        throw ApiException(
          statusCode: response.statusCode,
          message: 'Request failed after ${attempt + 1} attempts',
        );
      } on SocketException {
        if (attempt < maxRetries - 1) {
          await _delay(attempt);
          continue;
        }
        throw ApiException(message: 'No internet connection');
      } on TimeoutException {
        if (attempt < maxRetries - 1) {
          await _delay(attempt);
          continue;
        }
        throw ApiException(message: 'Request timed out');
      } on ApiException {
        rethrow;
      } catch (e) {
        throw ApiException(message: 'Unexpected error: $e');
      }
    }

    throw ApiException(message: 'Request failed after $maxRetries attempts');
  }

  /// Delay with exponential backoff
  Future<void> _delay(int attempt) async {
    final delayMs = initialDelay.inMilliseconds * (1 << attempt);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// Check if device has internet connectivity
  static Future<bool> hasConnection() async {
    try {
      final result = await InternetAddress.lookup('github.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
