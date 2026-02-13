import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';
import 'user_service.dart';

/// FCM 푸시 알림 서비스
///
/// Firebase Cloud Messaging을 통한 푸시 알림 수신 및 처리
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final UserService _userService = UserService();

  bool _isInitialized = false;
  String? _nickname;

  /// 알림 클릭 시 콜백
  Function(Map<String, dynamic>)? onNotificationTap;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. 권한 요청
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('✅ 알림 권한 승인됨');
      } else {
        debugPrint('⚠️ 알림 권한 거부됨');
        return;
      }

      // 2. FCM 토큰 가져오기
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint('📱 FCM 토큰: ${token.substring(0, 20)}...');
        await _registerTokenToServer(token);
      }

      // 3. 토큰 갱신 리스너
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM 토큰 갱신됨');
        _registerTokenToServer(newToken);
      });

      // 4. 로컬 알림 초기화
      await _initLocalNotifications();

      // 5. 포그라운드 메시지 수신
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. 백그라운드에서 앱 열었을 때
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 7. 앱 종료 상태에서 알림으로 시작했을 때
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // 8. 닉네임 가져오기
      await _loadNickname();

      _isInitialized = true;
      debugPrint('✅ NotificationService 초기화 완료');
    } catch (e) {
      debugPrint('❌ NotificationService 초기화 실패: $e');
    }
  }

  /// 서버에서 닉네임 로드
  Future<void> _loadNickname() async {
    try {
      final user = await _userService.getMe();
      _nickname = user.nickname;
      debugPrint('📛 닉네임 로드: $_nickname');
    } catch (e) {
      debugPrint('⚠️ 닉네임 로드 실패: $e');
    }
  }

  /// 로컬 알림 초기화
  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: iOS);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Android 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      'pangpangpang_notification',
      '팡팡팡 알림',
      description: '곰팡이 예방 알림',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// FCM 토큰을 서버에 등록
  Future<void> _registerTokenToServer(String token) async {
    try {
      final apiService = ApiService();
      final jwtToken = await apiService.getToken();

      // JWT 토큰이 없으면 (로그인 전) 등록 스킵
      if (jwtToken == null) {
        debugPrint('⚠️ JWT 토큰 없음 - FCM 토큰 등록 보류');
        return;
      }

      await apiService.dio.post('/notifications/register-token', data: {
        'fcm_token': token,
      });
      debugPrint('✅ FCM 토큰 서버 등록 완료');
    } catch (e) {
      debugPrint('❌ FCM 토큰 등록 실패: $e');
    }
  }

  /// 로그인 후 FCM 토큰 등록 (명시적 호출용)
  Future<void> registerFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _registerTokenToServer(token);
      }
    } catch (e) {
      debugPrint('❌ FCM 토큰 등록 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리 (앱 실행 중)
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('📩 포그라운드 메시지: ${message.notification?.title}');

    final body = message.notification?.body ?? '';
    final displayBody = _nickname != null ? '$_nickname님, $body' : body;

    // 로컬 알림으로 표시
    await _showLocalNotification(
      title: message.notification?.title ?? '알림',
      body: displayBody,
      payload: jsonEncode(message.data),
    );
  }

  /// 백그라운드에서 알림 클릭 시
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 알림 클릭: ${message.notification?.title}');

    if (onNotificationTap != null) {
      onNotificationTap!(message.data);
    }
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'pangpangpang_notification',
      '팡팡팡 알림',
      channelDescription: '곰팡이 예방 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iOS = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: android, iOS: iOS);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 로컬 알림 클릭 시 동작
  void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload != null && onNotificationTap != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        onNotificationTap!(data);
      } catch (e) {
        debugPrint('❌ 페이로드 파싱 실패: $e');
      }
    }
  }
}
