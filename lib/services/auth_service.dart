import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 백엔드 로그인 응답 모델
class AuthResponse {
  final String accessToken;
  final String tokenType;
  final int userId;
  final bool isNewUser;
  final String? nickname;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.userId,
    required this.isNewUser,
    this.nickname,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      userId: json['user_id'],
      isNewUser: json['is_new_user'],
      nickname: json['nickname'],
    );
  }
}

/// 인증 관련 API 서비스
class AuthService {
  final ApiService _apiService = ApiService();

  /// 카카오 토큰으로 백엔드 로그인
  /// 백엔드에서 카카오 토큰 검증 후 JWT 발급
  Future<AuthResponse> loginWithKakao(String kakaoAccessToken) async {
    try {
      final response = await _apiService.dio.post(
        '/auth/kakao',
        data: {
          'access_token': kakaoAccessToken,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // JWT 토큰 저장
      await _apiService.saveToken(authResponse.accessToken);

      debugPrint('[AuthService] 로그인 성공 - userId: ${authResponse.userId}, isNewUser: ${authResponse.isNewUser}');

      return authResponse;
    } on DioException catch (e) {
      debugPrint('[AuthService] 로그인 실패: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// 로그아웃 (토큰 삭제)
  Future<void> logout() async {
    await _apiService.clearToken();
    debugPrint('[AuthService] 로그아웃 완료');
  }

  /// 저장된 JWT 토큰 확인
  Future<bool> hasValidToken() async {
    final token = await _apiService.getToken();
    return token != null;
  }

  /// 에러 핸들링
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      final message = data is Map ? data['message'] ?? '로그인 실패' : '로그인 실패';
      return Exception(message);
    }
    return Exception('서버 연결에 실패했습니다.');
  }
}
