// 알림 데이터 모델
//
// TODO: 추후 백엔드 API 연동 시 아래 형식으로 데이터를 받아올 예정
// GET /api/notifications
// Response: { "notifications": [NotificationItem, ...] }

enum NotificationType {
  riskAlert,    // 곰팡이 위험도 알림
  update,       // 앱 업데이트/공지사항
  tip,          // 환기 팁 등
  diagnosis,    // 진단 결과 알림
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

  /// TODO: 백엔드 연동 시 사용할 JSON 파싱
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.update,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // 알림 타입별 아이콘
  String get icon {
    switch (type) {
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
