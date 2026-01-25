import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // 사용자 정보 로드
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: 실제 API에서 사용자 정보 가져오기
      await Future.delayed(const Duration(milliseconds: 500));

      _user = UserModel(
        id: '1',
        email: 'user@kakao.com',
        nickname: '회원님',
        isOnboardingCompleted: true,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 정보 업데이트
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  // 집 정보 업데이트
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
