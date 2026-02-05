import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

/// 알림 상태 관리 Provider
///
/// 알림 목록 조회, 읽음 처리, 삭제, 설정 변경 등을 담당
class NotificationProvider with ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  bool _notificationEnabled = true;
  int _unreadCount = 0;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  bool get notificationEnabled => _notificationEnabled;
  int get unreadCount => _unreadCount;

  final ApiService _apiService = ApiService();

  /// 알림 목록 불러오기
  Future<void> fetchNotifications({int limit = 50, int offset = 0}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get(
        '/notifications/',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      final List<dynamic> data = response.data;
      _notifications =
          data.map((json) => NotificationItem.fromJson(json)).toList();

      _updateUnreadCount();
      debugPrint('✅ 알림 ${_notifications.length}개 로드 완료');
    } catch (e) {
      debugPrint('❌ 알림 목록 조회 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 읽지 않은 알림 개수 조회
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.dio.get('/notifications/unread-count');
      _unreadCount = response.data['unread_count'] ?? 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 읽지 않은 알림 개수 조회 실패: $e');
    }
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.dio.patch('/notifications/$notificationId/read');

      // 로컬 상태 업데이트
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final oldNotification = _notifications[index];
        _notifications[index] = NotificationItem(
          id: oldNotification.id,
          type: oldNotification.type,
          title: oldNotification.title,
          message: oldNotification.message,
          createdAt: oldNotification.createdAt,
          isRead: true,
          data: oldNotification.data,
        );
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ 알림 읽음 처리 실패: $e');
    }
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      await _apiService.dio.patch('/notifications/read-all');

      // 로컬 상태 업데이트
      _notifications = _notifications
          .map((n) => NotificationItem(
                id: n.id,
                type: n.type,
                title: n.title,
                message: n.message,
                createdAt: n.createdAt,
                isRead: true,
                data: n.data,
              ))
          .toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 전체 읽음 처리 실패: $e');
    }
  }

  /// 알림 삭제
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _apiService.dio.delete('/notifications/$notificationId');

      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ 알림 삭제 실패: $e');
      return false;
    }
  }

  /// 모든 알림 삭제
  Future<bool> deleteAllNotifications() async {
    try {
      await _apiService.dio.delete('/notifications/delete-all');

      _notifications.clear();
      _unreadCount = 0;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ 전체 알림 삭제 실패: $e');
      return false;
    }
  }

  /// 알림 설정 조회
  Future<void> fetchNotificationSettings() async {
    try {
      final response = await _apiService.dio.get('/notifications/settings');
      _notificationEnabled = response.data['notification_enabled'] ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ 알림 설정 조회 실패: $e');
    }
  }

  /// 알림 설정 변경 (ON/OFF)
  Future<bool> updateNotificationSettings(bool enabled) async {
    try {
      await _apiService.dio.put('/notifications/settings', data: {
        'notification_enabled': enabled,
      });

      _notificationEnabled = enabled;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ 알림 설정 변경 실패: $e');
      return false;
    }
  }

  /// 읽지 않은 알림 개수 로컬 업데이트
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }

  /// 테스트 알림 전송
  Future<bool> sendTestNotification() async {
    try {
      final response = await _apiService.dio.post('/notifications/test-send');
      return response.data['status'] == 'success';
    } catch (e) {
      debugPrint('❌ 테스트 알림 전송 실패: $e');
      return false;
    }
  }

  /// 초기화 (로그아웃 시)
  void clear() {
    _notifications = [];
    _unreadCount = 0;
    _notificationEnabled = true;
    notifyListeners();
  }
}
