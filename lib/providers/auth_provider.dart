import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  final _storage = const FlutterSecureStorage();

  // ============================================================
  // 🔧 개발 모드 설정 - 에뮬레이터에서 카카오 로그인 우회
  // 실제 기기 테스트 시 false로 변경하세요
  // ============================================================
  static const bool _devBypassKakaoLogin = true;
  // ============================================================

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  static bool get isDevMode => _devBypassKakaoLogin;

  // 카카오 로그인
  Future<bool> loginWithKakao() async {
    _isLoading = true;
    notifyListeners();

    // 개발 모드: 카카오 로그인 우회
    if (_devBypassKakaoLogin) {
      debugPrint('🔧 [개발 모드] 카카오 로그인 우회 - 더미 사용자로 로그인');
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 효과

      _user = UserModel(
        id: 'dev_user_001',
        email: 'dev@test.com',
        nickname: '개발자',
        profileImage: null,
        isOnboardingCompleted: false,
      );

      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      OAuthToken token;

      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인
          token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('카카오톡으로 로그인 성공');
        } catch (error) {
          debugPrint('카카오톡으로 로그인 실패 $error');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (선택 사항)
          if (error is PlatformException && error.code == 'CANCELED') {
            _isLoading = false;
            notifyListeners();
            return false;
          }
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
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
        // 카카오톡 미설치 시 카카오계정으로 로그인
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

      // 토큰 저장
      await _saveToken(token);

      // 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();

      // 로컬 UserModel로 변환
      _user = UserModel(
        id: kakaoUser.id.toString(),
        email: kakaoUser.kakaoAccount?.email ?? '',
        nickname: kakaoUser.kakaoAccount?.profile?.nickname ?? '사용자',
        profileImage: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        isOnboardingCompleted: false, // 최초 로그인 시 false, 서버에서 확인 필요
      );

      _isLoggedIn = true;

      // TODO: 백엔드 서버로 토큰 전송 및 JWT 발급
      // await _sendTokenToServer(token.accessToken);

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

  // 토큰 저장
  Future<void> _saveToken(OAuthToken token) async {
    await _storage.write(key: 'kakao_access_token', value: token.accessToken);
    if (token.refreshToken != null) {
      await _storage.write(
          key: 'kakao_refresh_token', value: token.refreshToken);
    }
  }

  // 저장된 토큰으로 자동 로그인
  Future<bool> autoLogin() async {
    // 개발 모드: 자동 로그인 건너뛰기 (매번 로그인 화면 표시)
    if (_devBypassKakaoLogin) {
      debugPrint('🔧 [개발 모드] 자동 로그인 건너뜀');
      return false;
    }

    try {
      final accessToken = await _storage.read(key: 'kakao_access_token');
      if (accessToken == null) {
        return false;
      }

      // 토큰 정보 확인
      final tokenInfo = await UserApi.instance.accessTokenInfo();
      debugPrint('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');

      // 사용자 정보 가져오기
      final kakaoUser = await UserApi.instance.me();

      _user = UserModel(
        id: kakaoUser.id.toString(),
        email: kakaoUser.kakaoAccount?.email ?? '',
        nickname: kakaoUser.kakaoAccount?.profile?.nickname ?? '사용자',
        profileImage: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
        isOnboardingCompleted: true, // 기존 사용자는 온보딩 완료로 간주
      );

      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('자동 로그인 실패 $e');
      // 토큰이 만료된 경우 삭제
      await _storage.delete(key: 'kakao_access_token');
      await _storage.delete(key: 'kakao_refresh_token');
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    // 개발 모드: 간단히 로그아웃 처리
    if (_devBypassKakaoLogin) {
      debugPrint('🔧 [개발 모드] 로그아웃');
      _user = null;
      _isLoggedIn = false;
      notifyListeners();
      return;
    }

    try {
      await UserApi.instance.logout();
      await _storage.delete(key: 'kakao_access_token');
      await _storage.delete(key: 'kakao_refresh_token');
      debugPrint('로그아웃 성공');
    } catch (error) {
      debugPrint('로그아웃 실패 $error');
    }

    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      await UserApi.instance.unlink();
      await _storage.delete(key: 'kakao_access_token');
      await _storage.delete(key: 'kakao_refresh_token');
      debugPrint('회원 탈퇴 성공');
    } catch (error) {
      debugPrint('회원 탈퇴 실패 $error');
    }

    _user = null;
    _isLoggedIn = false;
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
      notifyListeners();

      // TODO: 백엔드에 온보딩 정보 저장
    }
  }

  // 사용자 정보 업데이트
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}
