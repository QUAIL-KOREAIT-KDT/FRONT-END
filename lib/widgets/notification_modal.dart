import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/notification.dart';
import '../providers/notification_provider.dart';

class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});

  /// 모달 표시 (static 메서드로 쉽게 호출)
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final notifications = provider.notifications;

        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '알림',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.gray800,
                          ),
                        ),
                        if (notifications.any((n) => !n.isRead)) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.pinkPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${notifications.where((n) => !n.isRead).length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        // 모두 읽음 버튼
                        if (notifications.any((n) => !n.isRead))
                          GestureDetector(
                            onTap: () => provider.markAllAsRead(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.mintLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '모두 읽음',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.mintPrimary,
                                ),
                              ),
                            ),
                          ),
                        // 모두 삭제 버튼
                        if (notifications.isNotEmpty)
                          GestureDetector(
                            onTap: () => _showDeleteAllConfirmDialog(
                              context,
                              provider,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '모두 삭제',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.danger,
                                ),
                              ),
                            ),
                          ),
                        // 닫기 버튼
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.gray100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppTheme.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: AppTheme.gray200),

              // 알림 목록
              Expanded(
                child: notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: 20,
                          endIndent: 20,
                          color: AppTheme.gray100,
                        ),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _NotificationTile(
                            notification: notification,
                            onTap: () {
                              if (!notification.isRead) {
                                provider.markAsRead(notification.id);
                              }
                            },
                            onDelete: () => _showDeleteConfirmDialog(
                              context,
                              provider,
                              notification,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllConfirmDialog(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('모든 알림 삭제'),
        content: const Text('모든 알림을 삭제하시겠습니까?\n삭제된 알림은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '취소',
              style: TextStyle(color: AppTheme.gray500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await provider.deleteAllNotifications();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? '모든 알림이 삭제되었습니다' : '알림 삭제에 실패했습니다',
                    ),
                    backgroundColor: success ? AppTheme.mintPrimary : AppTheme.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Text(
              '모두 삭제',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    NotificationProvider provider,
    NotificationItem notification,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('알림 삭제'),
        content: const Text('이 알림을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '취소',
              style: TextStyle(color: AppTheme.gray500),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.deleteNotification(notification.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('알림이 삭제되었습니다'),
                    backgroundColor: AppTheme.mintPrimary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: Text(
              '삭제',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTheme.gray100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: AppTheme.gray400,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '알림이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '새로운 소식이 있으면 알려드릴게요!',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _NotificationTile({
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.daily:
        return AppTheme.mintPrimary;
      case NotificationType.notice:
        return AppTheme.mintPrimary;
      case NotificationType.riskAlert:
        return AppTheme.danger;
      case NotificationType.update:
        return AppTheme.mintPrimary;
      case NotificationType.tip:
        return AppTheme.caution;
      case NotificationType.diagnosis:
        return AppTheme.pinkPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: notification.isRead
            ? Colors.white
            : AppTheme.mintLight.withValues(alpha: 0.3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  notification.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppTheme.gray800,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.pinkPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.gray400,
                    ),
                  ),
                ],
              ),
            ),

            // 삭제 버튼
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppTheme.gray400,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
