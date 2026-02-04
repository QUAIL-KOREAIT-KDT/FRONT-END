// 알림 데이터 모델
//
// 백엔드 API 연동
// GET /api/notifications
// Response: [NotificationItem, ...]

enum NotificationType {
  daily, // 매일 8시 정기 알림
  notice, // 공지사항
  riskAlert, // 곰팡이 위험도 알림 (레거시)
  update, // 앱 업데이트 (레거시)
  tip, // 환기 팁 등 (레거시)
  diagnosis, // 진단 결과 알림 (레거시)
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data; // 추가 데이터 (위험도 수치 등)

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  /// 백엔드 JSON 파싱
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'].toString(),
      type: _parseType(json['type'] as String?),
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// 타입 문자열 파싱
  static NotificationType _parseType(String? typeStr) {
    switch (typeStr) {
      case 'daily':
        return NotificationType.daily;
      case 'notice':
        return NotificationType.notice;
      case 'riskAlert':
        return NotificationType.riskAlert;
      case 'update':
        return NotificationType.update;
      case 'tip':
        return NotificationType.tip;
      case 'diagnosis':
        return NotificationType.diagnosis;
      default:
        return NotificationType.daily;
    }
  }

  // 알림 타입별 아이콘
  String get icon {
    switch (type) {
      case NotificationType.daily:
        return '🌤️';
      case NotificationType.notice:
        return '📢';
      case NotificationType.riskAlert:
        return '⚠️';
      case NotificationType.update:
        return '📢';
      case NotificationType.tip:
        return '💡';
      case NotificationType.diagnosis:
        return '🔬';
    }
  }

  // 상대적 시간 표시 (예: "방금 전", "1시간 전")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${createdAt.month}월 ${createdAt.day}일';
    }
  }
}
