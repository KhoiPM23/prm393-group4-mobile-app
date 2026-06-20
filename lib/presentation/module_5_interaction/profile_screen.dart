import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../widgets/vibe_bottom_nav_bar.dart';

/// Màn hình Hồ sơ & Quản lý Chuyến đi VibeLocals
/// Route: /profile
/// Source: h_s_qu_n_l_chuy_n_i_vibelocals/code.html
/// Design:
///   - Glassmorphic TopAppBar (menu icon + VibeLocals title + avatar)
///   - Profile section (big avatar + edit overlay + name + email + edit link)
///   - "Chuyến đi của tôi" section with Trip Cards
///   - Settings menu (Bảo mật, Thanh toán, Đăng xuất)
///   - Bottom navigation
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 3;

  final List<_TripCard> _trips = const [
    _TripCard(
      name: 'Pine Mist Cabin',
      location: 'Đà Lạt',
      dates: '12 Th10 - 15 Th10',
      price: '5.550.000đ',
      status: 'Sắp đi',
      statusColor: AppColors.primary,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDGKDUoW-W3uCUJ5Nr8o_h2iDeoOmQG-HBG6Cza2CfXcC776xbMTRKcXtnCOsYm3PSlrfPdHaBdQGs0lL7_p8lWzAebRFojPb3-yb9BjkrTI-mPcF_L44OuHg07SG_nDo_Y2Jkdpe5YjTuMg_qIE-8TvgbshA48XBuAzk3hUVzlXumjw5XqlTpx_WPYPodWEZ2HzQJoonS1QWgLE6PmgGTlC_V_dH7eo78RNo4Ih53lC07CpGxv2WpqadRIpOADj4d1PJ6Nb8kzRlc',
    ),
    _TripCard(
      name: 'Villa Hội An Heritage',
      location: 'Hội An',
      dates: '05 Th08 - 08 Th08',
      price: '4.500.000đ',
      status: 'Đã hoàn thành',
      statusColor: AppColors.onTertiaryContainer,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCJewgMQ2BQcmbNN7-SFroruTgmooTarzm4n18nQE3pLjP9IFFcI32NUL6q3QPcgV8honmToE63FNwVyYBzuylzlSML0C24eICnhcQGAVJieGfg4RVde6d_aTsMnuVExh_OSrsEcbW1PqV9xoUh5x3PTQ4zmGHJUMcnsu6SPZzoGVZOtE83zW0A3sk4WAPBjYoV-tVtvbPzWq8XGuRgQ4No3HSNUfsv13Fi-gcwqxfoJ3bIYT7uKXXy9PvYdy1KmJPAldZhPN_myiQ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacer for AppBar
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
              // Profile Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: _ProfileCard(),
                ),
              ),
              const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl)),
              // My Trips Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chuyến đi của tôi',
                            style: AppTextStyles.titleLg.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'Tất cả',
                              style: AppTextStyles.labelLg.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ..._trips.map(
                          (t) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: AppSpacing.md),
                                child: _TripCardWidget(trip: t),
                              )),
                    ],
                  ),
                ),
              ),
              // Settings Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  child: _SettingsSection(
                    onSecurityTap: () =>
                        Navigator.of(context)
                            .pushNamed('/forgot-password'),
                    onLogoutTap: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login', (_) => false),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          // Fixed AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _ProfileAppBar(),
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

class _ProfileAppBar extends StatelessWidget {
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
                  onPressed: () {},
                  icon: const Icon(Icons.menu,
                      color: AppColors.primary),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(
                        AppTouchTarget.minSize,
                        AppTouchTarget.minSize),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'VibeLocals',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.outlineVariant),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDbikBs8fi39-USfpcCOWFesPerbQdMPUkzVX28B5He9XfXTldpWZiR2kNwE3DhKmjg5UrnPZgGSD6_iop0PwzmzFL8ULIGua5C1zQ3BU55qQjSDVxesTFAABNtaA4ZYWEmHV0QZRTXqQHHnc_H_Sc3NU4U4eYLRg5oaKLn_7j1scHxerFWYuA0PujVkiW9-xixS-xUYL96j3HdOpFTOiK4KP9d-NTnbpd8S4aYtkwAjSTnukMg_ycZOlDIKiDO7SMwzH050Jrwe6U',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person,
                              color: AppColors.outline),
                    ),
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

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar with edit button
          Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuC_vmSj0rgrsNCQfKQxAou_Hwu6IBpNx5Niw1DnuUZRWFSjtHwmMU2w2Kqe-sKoygZPscetd1pTz7GrKJA2z5EeRj4MsgP9WlCcoBu_tRby-hHP5lB9ThToMBkxnoAHaiK8YzQj6wTD3x-dzhsbU5OFrrcpZpg2oSACOZuNnns0p3G164mW5Nlczp8YiqDYrgPfeLOS0uhb3cWo-lgpGgMdHlkSHC_t2D5jPlZrD1cFGAeCjQCvQXBemuhHyb4imIkH7pzA3T3-Eno',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      child: Icon(Icons.person,
                          size: 56, color: AppColors.outline),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit,
                      color: AppColors.onPrimary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Phan Minh Khôi',
            style: AppTextStyles.headlineLgMobile.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'khoi.phan@email.com',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () {},
            child: Text(
              'Chỉnh sửa',
              style: AppTextStyles.labelLg.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCardWidget extends StatelessWidget {
  final _TripCard trip;
  const _TripCardWidget({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          SizedBox(
            height: 160,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  trip.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.surfaceContainerHigh,
                  ),
                ),
                // Status badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: trip.statusColor,
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      trip.status,
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 2),
                          Text(
                            trip.location,
                            style: AppTextStyles.labelMd.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trip.dates,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.price,
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final VoidCallback? onSecurityTap, onLogoutTap;
  const _SettingsSection({this.onSecurityTap, this.onLogoutTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 4, bottom: AppSpacing.md),
          child: Text(
            'Cài đặt',
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
        // Security
        _SettingsItem(
          icon: Icons.shield_outlined,
          label: 'Cài đặt bảo mật',
          onTap: onSecurityTap,
        ),
        const SizedBox(height: AppSpacing.sm),
        // Payment
        _SettingsItem(
          icon: Icons.credit_card_outlined,
          label: 'Phương thức thanh toán đã lưu',
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.sm),
        // Logout
        _SettingsItem(
          icon: Icons.logout,
          label: 'Đăng xuất',
          isDestructive: true,
          onTap: onLogoutTap,
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? AppColors.error : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.errorContainer.withValues(alpha: 0.2)
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: isDestructive
                ? AppColors.error.withValues(alpha: 0.1)
                : AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLg.copyWith(
                  color: isDestructive
                      ? AppColors.error
                      : AppColors.onSurface,
                  fontWeight: isDestructive
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDestructive
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard {
  final String name, location, dates, price, status, imageUrl;
  final Color statusColor;
  const _TripCard({
    required this.name,
    required this.location,
    required this.dates,
    required this.price,
    required this.status,
    required this.statusColor,
    required this.imageUrl,
  });
}
