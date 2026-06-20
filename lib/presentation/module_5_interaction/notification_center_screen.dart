import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/vibe_cards.dart';
import '../widgets/vibe_bottom_nav_bar.dart';

/// Màn hình Trung tâm Thông báo VibeLocals
/// Route: /notifications
/// Source: trung_t_m_th_ng_b_o_vibelocals/code.html
/// Design:
///   - Glassmorphic AppBar (back + title "Thông báo" + settings icon)
///   - Horizontal filter chips (Tất cả, Chuyến đi, Cập nhật, Khuyến mãi)
///   - Notification list (unread + read states)
///   - Empty state illustration
///   - Bottom nav bar
class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends State<NotificationCenterScreen> {
  int _selectedFilter = 0;
  int _currentNavIndex = 0;

  final List<String> _filters = [
    'Tất cả',
    'Chuyến đi',
    'Cập nhật',
    'Khuyến mãi',
  ];

  final List<_NotifData> _notifications = [
    _NotifData(
      title: 'Đặt phòng thành công',
      body:
          'Chuyến đi của bạn tại Villa Hội An Heritage đã được xác nhận thành công!',
      timeAgo: '2 giờ trước',
      icon: Icons.luggage,
      iconBgColor: AppColors.primaryContainer,
      iconColor: AppColors.onPrimaryContainer,
      isUnread: true,
      filter: 1,
    ),
    _NotifData(
      title: 'Tin nhắn mới',
      body:
          'Chủ nhà Lâm Nguyễn vừa gửi tin nhắn cho bạn về lịch trình nhận phòng.',
      timeAgo: '5 giờ trước',
      icon: Icons.chat_outlined,
      iconBgColor: AppColors.onTertiaryContainer,
      iconColor: Colors.white,
      isUnread: false,
      filter: 2,
    ),
    _NotifData(
      title: 'Ưu đãi đặc biệt',
      body:
          'Giảm ngay 10% cho lần đặt phòng tiếp theo tại Đà Lạt. Hãy khám phá ngay các homestay cao cấp của chúng tôi.',
      timeAgo: '1 ngày trước',
      icon: Icons.celebration_outlined,
      iconBgColor: AppColors.secondaryContainer,
      iconColor: AppColors.onSecondaryContainer,
      isUnread: false,
      filter: 3,
    ),
    _NotifData(
      title: 'Cập nhật tài khoản',
      body:
          'Thông tin cá nhân của bạn đã được cập nhật thành công theo tiêu chuẩn bảo mật mới.',
      timeAgo: '3 ngày trước',
      icon: Icons.verified_user_outlined,
      iconBgColor: AppColors.surfaceVariant,
      iconColor: AppColors.onSurfaceVariant,
      isUnread: false,
      filter: 2,
    ),
  ];

  List<_NotifData> get _filtered {
    if (_selectedFilter == 0) return _notifications;
    return _notifications
        .where((n) => n.filter == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer for fixed AppBar
              const SliverToBoxAdapter(child: SizedBox(height: 72)),
              // Filter chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    itemCount: _filters.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final isSelected = _selectedFilter == i;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                                AppRadius.full),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outlineVariant
                                      .withValues(alpha: 0.3),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _filters[i],
                            style: AppTextStyles.labelLg.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              // Notification list
              if (_filtered.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  sliver: SliverList.separated(
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, i) {
                      final n = _filtered[i];
                      return NotificationItemCard(
                        title: n.title,
                        body: n.body,
                        timeAgo: n.timeAgo,
                        icon: n.icon,
                        iconBgColor: n.iconBgColor,
                        iconColor: n.iconColor,
                        isUnread: n.isUnread,
                      );
                    },
                  ),
                ),
              // "You've seen all" indicator
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: AppSpacing.xxl, bottom: 120),
                  child: Opacity(
                    opacity: 0.4,
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          transform:
                              Matrix4.rotationZ(0.05),
                          decoration: BoxDecoration(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.notifications_paused_outlined,
                            size: 36,
                            color: AppColors.outline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Bạn đã xem hết thông báo gần đây',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Fixed Top AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _NotifAppBar(),
          ),
          // Bottom Nav
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VibeBottomNavBar(
              currentIndex: _currentNavIndex,
              onTap: (i) {
                setState(() => _currentNavIndex = i);
                if (i == 0) {
                  Navigator.of(context)
                      .pushReplacementNamed('/home');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface.withValues(alpha: 0.85),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.onSurface),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(
                        AppTouchTarget.minSize,
                        AppTouchTarget.minSize),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Thông báo',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined,
                      color: AppColors.onSurfaceVariant),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(
                        AppTouchTarget.minSize,
                        AppTouchTarget.minSize),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              size: 44,
              color: AppColors.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Không có thông báo',
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifData {
  final String title, body, timeAgo;
  final IconData icon;
  final Color iconBgColor, iconColor;
  final bool isUnread;
  final int filter;
  const _NotifData({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.isUnread,
    required this.filter,
  });
}
