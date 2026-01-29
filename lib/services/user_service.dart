import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 사용자 정보 응답 모델
class UserResponse {
  final int id;
  final String kakaoId;
  final String? nickname;
  final String? windowDirection;
  final String? underground;
  final String? address;
  final String? outputAddress;
  final double? indoorTemp;
  final double? indoorHumidity;
  final DateTime? createdAt;

  UserResponse({
    required this.id,
    required this.kakaoId,
    this.nickname,
    this.windowDirection,
    this.underground,
    this.address,
    this.outputAddress,
    this.indoorTemp,
    this.indoorHumidity,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'],
      kakaoId: json['kakao_id'],
      nickname: json['nickname'],
      windowDirection: json['window_direction'],
      underground: json['underground'],
      address: json['address'],
      outputAddress: json['output_address'],
      indoorTemp: json['indoor_temp']?.toDouble(),
      indoorHumidity: json['indoor_humidity']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// 더미 데이터
  static UserResponse dummy() {
    return UserResponse(
      id: 1,
      kakaoId: 'dummy_kakao_id',
      nickname: '회원님',
      windowDirection: 'S',
      underground: null,
      address: '서울특별시',
      outputAddress: '서울',
      indoorTemp: 22.0,
      indoorHumidity: 55.0,
      createdAt: DateTime.now(),
    );
  }
}

/// 온보딩/프로필 업데이트 요청 모델
class UserProfileRequest {
  final String nickname;
  final String address;
  final String underground;
  final String windowDirection;
  final double? indoorTemp;
  final double? indoorHumidity;

  UserProfileRequest({
    required this.nickname,
    required this.address,
    required this.underground,
    required this.windowDirection,
    this.indoorTemp,
    this.indoorHumidity,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'address': address,
      'underground': underground,
      'window_direction': windowDirection,
      'indoor_temp': indoorTemp,
      'indoor_humidity': indoorHumidity,
    };
  }
}

/// 부분 업데이트용 요청 모델 (변경할 필드만 전송)
class UserProfilePartialUpdate {
  final String? nickname;
  final String? address;
  final String? underground;
  final String? windowDirection;
  final double? indoorTemp;
  final double? indoorHumidity;

  UserProfilePartialUpdate({
    this.nickname,
    this.address,
    this.underground,
    this.windowDirection,
    this.indoorTemp,
    this.indoorHumidity,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (nickname != null) data['nickname'] = nickname;
    if (address != null) data['address'] = address;
    if (underground != null) data['underground'] = underground;
    if (windowDirection != null) data['window_direction'] = windowDirection;
    if (indoorTemp != null) data['indoor_temp'] = indoorTemp;
    if (indoorHumidity != null) data['indoor_humidity'] = indoorHumidity;
    return data;
  }
}

/// 사용자 API 서비스
class UserService {
  final ApiService _apiService = ApiService();

  /// 내 정보 조회
  Future<UserResponse> getMe() async {
    try {
      final response = await _apiService.dio.get('/users/me');
      debugPrint('[UserService] 내 정보 조회 성공');
      return UserResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[UserService] 내 정보 조회 실패: ${e.response?.data}');
      // API 실패 시 더미 데이터 반환
      debugPrint('[UserService] 더미 데이터 사용');
      return UserResponse.dummy();
    }
  }

  /// 온보딩 (초기 정보 등록)
  Future<bool> onboarding(UserProfileRequest data) async {
    try {
      await _apiService.dio.post('/users/onboarding', data: data.toJson());
      debugPrint('[UserService] 온보딩 성공');
      return true;
    } on DioException catch (e) {
      debugPrint('[UserService] 온보딩 실패: ${e.response?.data}');
      return false;
    }
  }

  /// 프로필 수정 (전체)
  Future<bool> updateProfile(UserProfileRequest data) async {
    try {
      await _apiService.dio.put('/users/profile-info', data: data.toJson());
      debugPrint('[UserService] 프로필 수정 성공');
      return true;
    } on DioException catch (e) {
      debugPrint('[UserService] 프로필 수정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// 프로필 부분 수정 (변경된 필드만)
  Future<bool> updateProfilePartial(UserProfilePartialUpdate data) async {
    try {
      await _apiService.dio.put('/users/profile-info', data: data.toJson());
      debugPrint('[UserService] 프로필 부분 수정 성공');
      return true;
    } on DioException catch (e) {
      debugPrint('[UserService] 프로필 부분 수정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// 회원 탈퇴
  Future<bool> withdraw() async {
    try {
      await _apiService.dio.delete('/users/withdraw');
      debugPrint('[UserService] 회원 탈퇴 성공');
      return true;
    } on DioException catch (e) {
      debugPrint('[UserService] 회원 탈퇴 실패: ${e.response?.data}');
      return false;
    }
  }
}
