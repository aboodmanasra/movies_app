import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../constants/api_constants.dart';

/// Creates and configures the single Dio instance used across the whole app.
///
/// Why centralize this?
///   • The TMDB API key is attached automatically to every request.
///   • Transient failures (TMDB 5xx, timeouts) are retried automatically.
///   • Base URL, timeouts, and logging are set once, in one place.
class DioClient {
  const DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    // 1) Attach the TMDB API key to every request's query parameters.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.queryParameters = {
            ...options.queryParameters,
            'api_key': ApiConfig.tmdbApiKey,
          };
          handler.next(options);
        },
      ),
    );

    // 2) Auto-retry transient failures. TMDB sometimes returns a 500 on a
    //    perfectly valid request, and mobile connections drop packets — a short
    //    pause + retry almost always succeeds, so the user never sees the blip.
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          const maxRetries = 2;
          final attempt =
              (error.requestOptions.extra['retry_attempt'] as int?) ?? 0;

          if (_isTransient(error) && attempt < maxRetries) {
            error.requestOptions.extra['retry_attempt'] = attempt + 1;
            // Back off a little more on each attempt (500ms, then 1000ms).
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              return handler.next(retryError);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 3) Readable request logging — debug builds only (never ships to users).
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false),
      );
    }

    return dio;
  }

  /// Transient = worth retrying: network/timeout issues, or a 5xx server error
  /// (like TMDB's occasional 500). A 4xx is NOT retried — that's a real client
  /// problem a retry won't fix.
  static bool _isTransient(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode ?? 0;
        return code >= 500;
      default:
        return false;
    }
  }
}
