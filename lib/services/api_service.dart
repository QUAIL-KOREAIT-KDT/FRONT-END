import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

/// 앱 전역 NavigatorKey — 강제 로그아웃 시 로그인 화면 이동에 사용
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  /// refresh 진행 중 중복 호출 방지
  bool _isRefreshing = false;

  /// refresh 대기 중인 요청 큐
  final List<Completer<void>> _requestQueue = [];

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 인터셉터 설정
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // JWT 토큰이 있으면 헤더에 추가
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('[API Request] ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
            '[API Response] ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint(
            '[API Error] ${error.response?.statusCode} ${error.message}');

        // 401 에러 + refresh 엔드포인트가 아닌 경우 → 토큰 갱신 시도
        if (error.response?.statusCode == 401 &&
            !error.requestOptions.path.contains('/auth/refresh')) {
          try {
            final response = await _handleTokenRefresh(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            // refresh도 실패 → 강제 로그아웃
            await _forceLogout();
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    ));
  }

  /// 토큰 갱신 처리 (동시 요청 큐잉)
  Future<Response> _handleTokenRefresh(RequestOptions failedRequest) async {
    if (_isRefreshing) {
      // 이미 refresh 중이면 큐에 넣고 대기
      final completer = Completer<void>();
      _requestQueue.add(completer);
      await completer.future;
      // 새 토큰으로 원래 요청 재시도
      final token = await _storage.read(key: 'jwt_token');
      failedRequest.headers['Authorization'] = 'Bearer $token';
      return _dio.fetch(failedRequest);
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) throw Exception('refresh token 없음');

      // refresh 요청 — refresh_token은 body에 담아서 전송
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccess = response.data['access_token'] as String;
      final newRefresh = response.data['refresh_token'] as String;

      // 새 토큰 저장
      await saveToken(newAccess);
      await saveRefreshToken(newRefresh);

      debugPrint('[ApiService] 토큰 갱신 성공');

      // 큐에 대기 중인 요청들 해제
      for (final completer in _requestQueue) {
        completer.complete();
      }
      _requestQueue.clear();

      // 원래 실패한 요청 재시도
      failedRequest.headers['Authorization'] = 'Bearer $newAccess';
      return _dio.fetch(failedRequest);
    } catch (e) {
      debugPrint('[ApiService] 토큰 갱신 실패: $e');
      // 큐에 대기 중인 요청들도 에러
      for (final completer in _requestQueue) {
        completer.completeError(e);
      }
      _requestQueue.clear();
      rethrow;
    } finally {
      _isRefreshing = false;
    }
  }

  /// 강제 로그아웃: 토큰 삭제 + Provider 상태 초기화 + 로그인 화면으로 이동
  Future<void> _forceLogout() async {
    debugPrint('[ApiService] 강제 로그아웃 — refresh 만료');
    await clearAllTokens();

    // 글로벌 navigatorKey로 로그인 화면 이동
    final ctx = navigatorKey.currentContext;
    if (ctx != null) {
      // AuthProvider 상태 초기화 (Provider 의존 없이 콜백으로 처리)
      _onForceLogout?.call();
      Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  /// 강제 로그아웃 시 외부(AuthProvider)에서 상태 초기화할 콜백
  static VoidCallback? _onForceLogout;
  static set onForceLogout(VoidCallback? cb) => _onForceLogout = cb;

  Dio get dio => _dio;

  // ─── JWT (access) 토큰 ───
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // ─── Refresh 토큰 ───
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> clearRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  // ─── 모든 토큰 삭제 ───
  Future<void> clearAllTokens() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }
}
