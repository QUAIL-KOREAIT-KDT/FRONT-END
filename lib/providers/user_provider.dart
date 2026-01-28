import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  final UserService _userService = UserService();

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // 사용자 정보 로드 (API 연동)
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _userService.getMe();

      _user = UserModel(
        id: response.id.toString(),
        nickname: response.nickname ?? '회원님',
        location: response.address,
        indoorTemperature: response.indoorTemp,
        houseDirection: response.windowDirection,
        isOnboardingCompleted: response.address != null,
      );

      debugPrint('[UserProvider] 사용자 정보 로드 완료: ${_user?.nickname}');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[UserProvider] 사용자 정보 로드 실패: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // 온보딩 완료 (API 연동)
  Future<bool> completeOnboarding({
    required String nickname,
    required String address,
    required String underground,
    required String windowDirection,
    double? indoorTemp,
    double? indoorHumidity,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userService.onboarding(
        UserProfileRequest(
          nickname: nickname,
          address: address,
          underground: underground,
          windowDirection: windowDirection,
          indoorTemp: indoorTemp,
          indoorHumidity: indoorHumidity,
        ),
      );

      if (success) {
        _user = _user?.copyWith(
          nickname: nickname,
          location: address,
          houseDirection: windowDirection,
          indoorTemperature: indoorTemp,
          isOnboardingCompleted: true,
        );
        debugPrint('[UserProvider] 온보딩 완료');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[UserProvider] 온보딩 실패: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 프로필 수정 (API 연동)
  Future<bool> updateProfile({
    required String nickname,
    required String address,
    required String underground,
    required String windowDirection,
    double? indoorTemp,
    double? indoorHumidity,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _userService.updateProfile(
        UserProfileRequest(
          nickname: nickname,
          address: address,
          underground: underground,
          windowDirection: windowDirection,
          indoorTemp: indoorTemp,
          indoorHumidity: indoorHumidity,
        ),
      );

      if (success) {
        _user = _user?.copyWith(
          nickname: nickname,
          location: address,
          houseDirection: windowDirection,
          indoorTemperature: indoorTemp,
        );
        debugPrint('[UserProvider] 프로필 수정 완료');
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[UserProvider] 프로필 수정 실패: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 회원 탈퇴 (API 연동)
  Future<bool> withdraw() async {
    try {
      final success = await _userService.withdraw();
      if (success) {
        _user = null;
        debugPrint('[UserProvider] 회원 탈퇴 완료');
      }
      notifyListeners();
      return success;
    } catch (e) {
      debugPrint('[UserProvider] 회원 탈퇴 실패: $e');
      return false;
    }
  }

  // 사용자 정보 업데이트 (로컬)
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // 집 정보 업데이트 (로컬)
  void updateHomeInfo({
    String? location,
    double? indoorTemperature,
    String? houseDirection,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        location: location ?? _user!.location,
        indoorTemperature: indoorTemperature ?? _user!.indoorTemperature,
        houseDirection: houseDirection ?? _user!.houseDirection,
      );
      notifyListeners();
    }
  }

  // 사용자 정보 초기화
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
