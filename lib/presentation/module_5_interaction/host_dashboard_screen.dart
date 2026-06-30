import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/repositories/firebase_message_repository.dart';
import '../../data/repositories/mock_property_repository.dart';
import '../../domain/entities/property_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import 'host_property_list_screen.dart';
import 'booking_schedule_screen.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  int _propertyCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPropertyCount();
  }

  Future<void> _loadPropertyCount() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final repo = MockPropertyRepository();
      final properties = await repo.getPropertiesByHost(authState.user.id);
      if (mounted) {
        setState(() {
          _propertyCount = properties.length;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập')));
    }

    final currentUser = authState.user;
    final messageRepo = FirebaseMessageRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.surface,
            elevation: 0,
            leading: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onSelected: (value) {
                if (value == 'profile') {
                  Navigator.of(context).pushNamed('/profile');
                } else if (value == 'logout') {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
              itemBuilder: (context) => [
                // const PopupMenuItem(
                //   value: 'profile',
                //   child: Row(
                //     children: [
                //       Icon(Icons.person_outline, size: 20),
                //       SizedBox(width: 8),
                //       Text('Hồ sơ'),
                //     ],
                //   ),
                // ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                const Icon(Icons.villa_rounded, color: AppColors.primary, size: 28),
                const SizedBox(width: 8),
                Text(
                  'VibeLocals',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              StreamBuilder(
                stream: messageRepo.getChatRooms(currentUser.id),
                builder: (context, snapshot) {
                  int unreadCount = 0;
                  if (snapshot.hasData) {
                    // Cộng dồn tất cả tin nhắn chưa đọc từ các phòng
                    unreadCount = snapshot.data!.fold(0, (sum, room) => sum + room.unreadCount);
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8),
                    child: Stack(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pushNamed('/inbox'),
                          icon: const Icon(Icons.chat_bubble_outline, size: 28, color: AppColors.primary),
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Chào ${currentUser.name},', style: AppTextStyles.headlineLgMobile),
                  Text('Chào mừng bạn quay lại bảng quản trị.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.outline)),
                  
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Hành động nhanh', style: AppTextStyles.titleLg),
                  const SizedBox(height: AppSpacing.md),
                  
                  _QuickActionTile(
                    title: 'Xem danh sách khách sạn',
                    subtitle: _isLoading ? 'Đang tải...' : 'Quản lý $_propertyCount địa điểm đang hoạt động',
                    icon: Icons.villa_rounded,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const HostPropertyListScreen(),
                      ));
                    },
                  ),
                  _QuickActionTile(
                    title: 'Lịch đặt phòng',
                    subtitle: 'Kiểm tra khách check-in và tình trạng phòng',
                    icon: Icons.event_note_rounded,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const BookingScheduleScreen(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.titleLg.copyWith(fontSize: 16)),
        subtitle: Text(subtitle, style: AppTextStyles.labelMd),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}
