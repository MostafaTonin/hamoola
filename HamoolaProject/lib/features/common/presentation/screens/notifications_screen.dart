import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/models/app_notification.dart';

enum NotificationTabFilter {
  all,
  bids,
  tracking,
  finance,
}

/// Screen displaying the notifications center with filter tabs, unread indicators,
/// mark all as read action, and contextual navigation to relevant screens.
class NotificationsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final ValueChanged<AppNotification>? onNotificationTap;

  const NotificationsScreen({
    super.key,
    this.onBack,
    this.onNotificationTap,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotificationTabFilter _currentFilter = NotificationTabFilter.all;
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.from(AppNotification.demoNotifications);
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<AppNotification> get _filteredNotifications {
    switch (_currentFilter) {
      case NotificationTabFilter.all:
        return _notifications;
      case NotificationTabFilter.bids:
        return _notifications
            .where((n) => n.category == NotificationCategory.bids)
            .toList();
      case NotificationTabFilter.tracking:
        return _notifications
            .where((n) => n.category == NotificationCategory.tracking)
            .toList();
      case NotificationTabFilter.finance:
        return _notifications
            .where((n) =>
                n.category == NotificationCategory.finance ||
                n.category == NotificationCategory.system)
            .toList();
    }
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.done_all_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              AppStrings.allNotificationsReadSuccess,
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleTapNotification(AppNotification notification) {
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      });
    }

    widget.onNotificationTap?.call(notification);
  }

  void _deleteNotification(AppNotification notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حذف الإشعار',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'تراجع',
          textColor: AppColors.primaryGold,
          onPressed: () {
            setState(() {
              _notifications.add(notification);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.navyDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
              size: 20,
            ),
            onPressed: widget.onBack ?? () => Navigator.maybePop(context),
          ),
          title: Text(
            AppStrings.notificationsTitle,
            style: GoogleFonts.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textWhite : AppColors.textMainLight,
            ),
          ),
          centerTitle: true,
          actions: [
            if (_unreadCount > 0)
              TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: Text(
                  AppStrings.markAllAsReadBtn,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGold,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.compactMax,
              ),
              child: Column(
                children: [
                  // 1. Filter Chips Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spaceMd,
                      vertical: AppDimensions.spaceXs,
                    ),
                    child: _buildFilterTabs(isDark),
                  ),
                  const SizedBox(height: 6),

                  // 2. Notification List or Empty State
                  Expanded(
                    child: _filteredNotifications.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.spaceMd,
                              vertical: AppDimensions.spaceSm,
                            ),
                            itemCount: _filteredNotifications.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (ctx, index) {
                              final item = _filteredNotifications[index];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                onDismissed: (_) => _deleteNotification(item),
                                child: _buildNotificationCard(item, isDark),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip(
            '${AppStrings.notifFilterAll} (${_notifications.length})',
            NotificationTabFilter.all,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            AppStrings.notifFilterBids,
            NotificationTabFilter.bids,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            AppStrings.notifFilterTracking,
            NotificationTabFilter.tracking,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            AppStrings.notifFilterFinance,
            NotificationTabFilter.finance,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    NotificationTabFilter filter,
    bool isDark,
  ) {
    final isSelected = _currentFilter == filter;
    return InkWell(
      onTap: () => setState(() => _currentFilter = filter),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGold
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGold
                : (isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF0F172A)
                : (isDark ? AppColors.textWhite : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification item, bool isDark) {
    return InkWell(
      onTap: () => _handleTapNotification(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? (item.isRead ? const Color(0xFF1E293B) : const Color(0xFF24334C))
              : (item.isRead ? Colors.white : const Color(0xFFFFFDF5)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !item.isRead
                ? AppColors.primaryGold.withValues(alpha: 0.4)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFE2E8F0)),
            width: !item.isRead ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon with Circle Container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.iconData,
                color: item.iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight:
                                item.isRead ? FontWeight.w700 : FontWeight.w900,
                            color: isDark
                                ? AppColors.textWhite
                                : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGold,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.body,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      height: 1.4,
                      color: isDark
                          ? AppColors.textSubtle
                          : const Color(0xFF64748B),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Time Ago + Action link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: isDark
                                ? AppColors.textSubtle
                                : AppColors.textMutedLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.timeAgo,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.textSubtle
                                  : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                      if (item.targetRoute != null)
                        Row(
                          children: [
                            Text(
                              'عرض التفاصيل',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 10,
                              color: AppColors.primaryGold,
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 32,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppStrings.emptyNotificationsTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textWhite : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.emptyNotificationsSubtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                color: isDark ? AppColors.textSubtle : AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
