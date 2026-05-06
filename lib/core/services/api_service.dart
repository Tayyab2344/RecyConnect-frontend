import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_constants.dart';
import 'secure_storage_service.dart';

class ApiService {
  static Dio? _dio;
  static CacheStore? _cacheStore;
  static CacheOptions? _cacheOptions;

  static Future<void> _init() async {
    if (_dio != null) return;

    final dir = await getApplicationDocumentsDirectory();
    _cacheStore = HiveCacheStore(dir.path);
    
    _cacheOptions = CacheOptions(
      store: _cacheStore,
      policy: CachePolicy.request, // Default policy: Use cache if available, else network
      hitCacheOnErrorExcept: [401, 403],
      maxStale: const Duration(days: 7),
      priority: CachePriority.normal,
    );

    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio!.interceptors.add(DioCacheInterceptor(options: _cacheOptions!));
    
    // Auth Interceptor
    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra['requiresAuth'] != false) {
          final token = await SecureStorageService.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
    ));
  }

  // Helper method for "Cache Then Network"
  void _triggerBackgroundRefresh(String endpoint, Map<String, dynamic>? queryParameters, bool requiresAuth) async {
    try {
      if (_dio == null) await _init();
      // Use refresh policy to force network and update the cache silently
      final refreshOptions = _cacheOptions!.copyWith(policy: CachePolicy.refresh).toOptions();
      refreshOptions.extra = {'requiresAuth': requiresAuth};
      
      await _dio!.get(
        endpoint,
        queryParameters: queryParameters,
        options: refreshOptions,
      );
      if (kDebugMode) {
        if (kDebugMode) print('Background cache refreshed for $endpoint');
      }
    } catch (e) {
      if (kDebugMode) print('Background refresh failed: $e');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = true, Map<String, dynamic>? query}) async {
    if (_dio == null) await _init();
    
    try {
      final response = await _dio!.get(
        endpoint,
        queryParameters: query,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      
      // If the response came from the cache, trigger a silent background refresh
      // so the next time we load this, it has fresh data! (Smart Delta/Refresh)
      final isFromCache = response.extra['@dio_cache_interceptor@'] == true;
      if (isFromCache) {
        _triggerBackgroundRefresh(endpoint, query, requiresAuth);
      }

      return _handleResponse(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
        throw Exception('Network error: ${e.message}');
      }
      return _handleResponse(e.response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    if (_dio == null) await _init();
    try {
      final response = await _dio!.post(
        endpoint,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleResponse(e.response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data, {bool requiresAuth = true}) async {
    if (_dio == null) await _init();
    try {
      final response = await _dio!.put(
        endpoint,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleResponse(e.response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = true}) async {
    if (_dio == null) await _init();
    try {
      final response = await _dio!.delete(
        endpoint,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleResponse(e.response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(Response? response) {
    if (response == null) {
       throw Exception('No response from server');
    }
    
    if (response.statusCode != null && (response.statusCode! >= 200 && response.statusCode! < 300 || response.statusCode == 304)) {
      if (response.data is String) {
        // Safe check for empty 304 response bodies to avoid json parsing errors
        if (response.data.toString().isEmpty && response.statusCode == 304) {
          return {};
        }
        return jsonDecode(response.data);
      }
      return response.data ?? {};
    } else {
      final errorBody = response.data is String ? jsonDecode(response.data) : response.data;
      final message = errorBody?['message'] ?? 'Unknown error';
      final errorDetail = errorBody?['error'] ?? '';
      throw Exception('HTTP ${response.statusCode}: $message${errorDetail.toString().isNotEmpty ? " ($errorDetail)" : ""}');
    }
  }
}
