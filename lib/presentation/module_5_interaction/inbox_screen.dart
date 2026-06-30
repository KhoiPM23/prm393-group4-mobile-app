import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/repositories/firebase_message_repository.dart';
import '../../domain/entities/chat_room_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(body: Center(child: Text('Vui lòng đăng nhập để xem tin nhắn.')));
        }

        final currentUser = state.user;
        final messageRepo = FirebaseMessageRepository();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              currentUser.role == UserRole.host ? 'Quản lý tin nhắn' : 'Tin nhắn của tôi', 
              style: AppTextStyles.headlineLgMobile
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            centerTitle: false,
          ),
          body: StreamBuilder<List<ChatRoomEntity>>(
            stream: messageRepo.getChatRooms(currentUser.id),
            builder: (context, snapshot) {
              // Log để debug
              if (snapshot.hasData) {
                print('Số lượng phòng chat tìm thấy cho ${currentUser.id}: ${snapshot.data!.length}');
                for(var room in snapshot.data!) {
                   print('Phòng: ${room.id}, Participants: ${room.participants}');
                }
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                print('Lỗi Stream Firestore: ${snapshot.error}');
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Lỗi tải dữ liệu: ${snapshot.error}\n\nVui lòng kiểm tra Logcat để biết thêm chi tiết.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final rooms = snapshot.data ?? [];
              if (rooms.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.outlineVariant),
                      const SizedBox(height: 16),
                      Text('Chưa có cuộc hội thoại nào.', 
                        style: AppTextStyles.bodyLg.copyWith(color: AppColors.outline)),
                      if (currentUser.role == UserRole.host)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('(Đang chờ khách hàng liên hệ)', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  // Tìm ID người kia
                  String otherUserId = '';
                  try {
                    otherUserId = room.participants.firstWhere((id) => id != currentUser.id);
                  } catch (_) {
                    // Trường hợp đặc biệt nếu phòng chỉ có 1 người hoặc dữ liệu lỗi
                    return const SizedBox.shrink();
                  }
                  
                  final otherUserData = room.metadata?[otherUserId] as Map<String, dynamic>?;
                  final otherName = otherUserData?['name'] ?? 'Người dùng';
                  final otherAvatar = otherUserData?['avatar'] ?? '';
                  final propertyTitle = room.metadata?['propertyTitle'] ?? 'Phòng chat';

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: otherAvatar.isNotEmpty ? NetworkImage(otherAvatar) : null,
                        child: otherAvatar.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(otherName, style: AppTextStyles.titleLg.copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          if (room.unreadCount > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                              child: Text('${room.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          Text(
                            '${room.lastMessageTimestamp.hour}:${room.lastMessageTimestamp.minute.toString().padLeft(2, '0')}',
                            style: AppTextStyles.labelMd.copyWith(color: AppColors.outline),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            room.lastMessage.isEmpty ? 'Bắt đầu trò chuyện...' : room.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              propertyTitle,
                              style: AppTextStyles.labelMd.copyWith(color: AppColors.primary, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed('/chat', arguments: {
                          'roomId': room.id,
                          'otherUserId': otherUserId,
                          'otherUserName': otherName,
                          'otherUserAvatar': otherAvatar,
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
