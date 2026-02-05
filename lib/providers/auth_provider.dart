import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../config/constants.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isNewUser = false;

  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();

  // ============================================================
  // 개발 모드 설정 - PRODUCTION 빌드 시 자동으로 false
  // flutter build apk --dart-define=PRODUCTION=true → 실제 카카오 로그인
  // flutter build apk (기본) → 개발용 로그인 우회
  // ============================================================
  static bool get _devBypassKakaoLogin => !AppConstants.isProduction;
  // ============================================================

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isNewUser => _isNewUser;
  static bool get isDevMode => _devBypassKakaoLogin;

  // 카카오 로그인
  Future<bool> loginWithKakao() async {
    _isLoading = true;
    notifyListeners();

    // 개발 모드: 카카오 로그인 우회 → 백엔드 개발용 로그인 API 호출
    if (_devBypassKakaoLogin) {
      debugPrint('[개발 모드] 카카오 로그인 우회 - 백엔드 개발용 로그인 API 호출');

      try {
        // 백엔드 개발용 로그인 API 호출
        final authResponse = await _authService.devLogin();

        _user = UserModel(
          id: authResponse.userId.toString(),
          nickname: authResponse.nickname ?? '테스트유저',
          isOnboardingCompleted: !authResponse.isNewUser,
        );

        _isLoggedIn = true;
        _isNewUser = authResponse.isNewUser;

        // FCM 토큰 등록
        await NotificationService().registerFCMToken();

        debugPrint(
            '[개발 모드] 로그인 완료 - userId: ${authResponse.userId}, isNewUser: $_isNewUser');

        _isLoading = false;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('[개발 모드] 백엔드 로그인 실패: $e');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    }

    try {
      OAuthToken token;

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡으로 로그인 성공');
        } catch (error) {
          debugPrint('카카오톡으로 로그인 실패 $error');

          if (error is PlatformException && error.code == 'CANCELED') {
            _isLoading = false;
            notifyListeners();
            return false;
          }

          try {
            token = await UserApi.instance.loginWithKakaoAccount();
            debugPrint('카카오계정으로 로그인 성공');
          } catch (error) {
            debugPrint('카카오계정으로 로그인 실패 $error');
            _isLoading = false;
            notifyListeners();
            return false;
          }
        }
      } else {
        try {
          token = await UserApi.instance.loginWithKakaoAccount();
          debugPrint('카카오계정으로 로그인 성공');
        } catch (error) {
          debugPrint('카카오계정으로 로그인 실패 $error');
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // 카카오 토큰 저장
      await _saveKakaoToken(token);

      // [백엔드 연동] 카카오 토큰으로 백엔드 로그인 → JWT 발급
      final authResponse = await _authService.loginWithKakao(token.accessToken);

      // 카카오 사용자 정보 가져오기 (이메일 등)
      String? kakaoEmail;
      try {
        final kakaoUser = await UserApi.instance.me();
        kakaoEmail = kakaoUser.kakaoAccount?.email;
      } catch (e) {
        debugPrint('[AuthProvider] 카카오 사용자 정보 조회 실패: $e');
      }

      // 사용자 정보 설정
      _user = UserModel(
        id: authResponse.userId.toString(),
        email: kakaoEmail, // 카카오 이메일 저장
        nickname: authResponse.nickname ?? '사용자',
        isOnboardingCompleted: !authResponse.isNewUser,
      );

      _isLoggedIn = true;
      _isNewUser = authResponse.isNewUser;

      // FCM 토큰 등록
      await NotificationService().registerFCMToken();

      debugPrint(
          '[AuthProvider] 로그인 완료 - userId: ${authResponse.userId}, isNewUser: $_isNewUser');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('카카오 로그인 에러: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 카카오 토큰 저장
  Future<void> _saveKakaoToken(OAuthToken token) async {
    await _storage.write(key: 'kakao_access_token', value: token.accessToken);
    if (token.refreshToken != null) {
      await _storage.write(
          key: 'kakao_refresh_token', value: token.refreshToken);
    }
  }

  // 저장된 토큰으로 자동 로그인
  Future<bool> autoLogin() async {
    if (_devBypassKakaoLogin) {
      debugPrint('[개발 모드] 자동 로그인 건너뜀');
      return false;
    }

    try {
      // JWT 토큰 확인
      final hasToken = await _authService.hasValidToken();
      if (!hasToken) {
        debugPrint('[AutoLogin] JWT 토큰 없음');
        return false;
      }

      // 카카오 토큰 확인
      final kakaoToken = await _storage.read(key: 'kakao_access_token');
      if (kakaoToken == null) {
        debugPrint('[AutoLogin] 카카오 토큰 없음');
        return false;
      }

      // 카카오 토큰 유효성 체크
      final tokenInfo = await UserApi.instance.accessTokenInfo();
      debugPrint('[AutoLogin] 토큰 유효 - expiresIn: ${tokenInfo.expiresIn}');

      // 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();

      _user = UserModel(
        id: kakaoUser.id.toString(),
        email: kakaoUser.kakaoAccount?.email ?? '',
        nickname: kakaoUser.kakaoAccount?.profile?.nickname ?? '사용자',
        profileImage: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        isOnboardingCompleted: true,
      );

      _isLoggedIn = true;
      _isNewUser = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AutoLogin] 실패: $e');
      // 토큰 정리
      await _clearAllTokens();
      return false;
    }
  }

  // 모든 토큰 삭제
  Future<void> _clearAllTokens() async {
    await _storage.delete(key: 'kakao_access_token');
    await _storage.delete(key: 'kakao_refresh_token');
    await _authService.logout();
  }

  // 로그아웃
  Future<void> logout() async {
    if (_devBypassKakaoLogin) {
      debugPrint('[개발 모드] 로그아웃');
      _user = null;
      _isLoggedIn = false;
      _isNewUser = false;
      notifyListeners();
      return;
    }

    try {
      await UserApi.instance.logout();
      debugPrint('카카오 로그아웃 성공');
    } catch (error) {
      debugPrint('카카오 로그아웃 실패: $error');
    }

    await _clearAllTokens();

    _user = null;
    _isLoggedIn = false;
    _isNewUser = false;
    notifyListeners();
  }

  // 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      await UserApi.instance.unlink();
      debugPrint('카카오 연결 해제 성공');
    } catch (error) {
      debugPrint('카카오 연결 해제 실패: $error');
    }

    await _clearAllTokens();

    _user = null;
    _isLoggedIn = false;
    _isNewUser = false;
    notifyListeners();
  }

  // 온보딩 완료
  void completeOnboarding({
    required String location,
    required double temperature,
    required String direction,
  }) {
    if (_user != null) {
      _user = _user!.copyWith(
        location: location,
        indoorTemperature: temperature,
        houseDirection: direction,
        isOnboardingCompleted: true,
      );
      _isNewUser = false;
      notifyListeners();
    }
  }

  // 사용자 정보 업데이트
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
