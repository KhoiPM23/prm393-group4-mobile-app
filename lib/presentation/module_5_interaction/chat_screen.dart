import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/repositories/firebase_message_repository.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';

/// Màn hình Chat với Chủ nhà VibeLocals
/// Route: /chat
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageRepository = FirebaseMessageRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  String? _roomId;
  String? _otherUserId;
  String? _otherUserName;
  String? _otherUserAvatar;
  UserEntity? _currentUser;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _roomId = args['roomId'];
      _otherUserId = args['otherUserId'];
      _otherUserName = args['otherUserName'];
      _otherUserAvatar = args['otherUserAvatar'];
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUser = authState.user;
      
      // Đánh dấu đã xem khi vào phòng chat
      if (_roomId != null) {
        _messageRepository.markAsRead(_roomId!, _currentUser!.id);
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _roomId == null || _currentUser == null || _otherUserId == null) return;
    
    _messageRepository.sendMessage(
      _roomId!,
      _currentUser!.id,
      _otherUserId!,
      text,
    );
    
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_roomId == null || _currentUser == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy phòng chat.')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ===== TOP APP BAR =====
          _ChatAppBar(
            name: _otherUserName ?? 'Chủ nhà',
            avatarUrl: _otherUserAvatar,
            onBackTap: () => Navigator.of(context).pop(),
          ),
          // ===== CHAT MESSAGES Realtime =====
          Expanded(
            child: StreamBuilder<List<MessageEntity>>(
              stream: _messageRepository.getMessages(_roomId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                
                return ListView.separated(
                  controller: _scrollController,
                  reverse: true, // Tin nhắn mới nhất ở dưới
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isOutgoing = msg.senderId == _currentUser!.id;
                    
                    return isOutgoing
                        ? _OutgoingBubble(message: msg)
                        : _IncomingBubble(
                            message: msg,
                            avatarUrl: _otherUserAvatar,
                          );
                  },
                );
              },
            ),
          ),
          // ===== INPUT BAR =====
          _ChatInputBar(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final VoidCallback? onBackTap;
  
  const _ChatAppBar({
    required this.name,
    this.avatarUrl,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface.withValues(alpha: 0.85),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onBackTap,
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.onSurface),
              ),
              const SizedBox(width: 4),
              Stack(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? Image.network(avatarUrl!, fit: BoxFit.cover)
                        : const CircleAvatar(
                            backgroundColor: AppColors.surfaceContainerHigh,
                            child: Icon(Icons.person, color: AppColors.outline),
                          ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.titleLg.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Đang trực tuyến',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final MessageEntity message;
  final String? avatarUrl;
  
  const _IncomingBubble({
    required this.message,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipOval(
          child: SizedBox(
            width: 30,
            height: 30,
            child: avatarUrl != null && avatarUrl!.isNotEmpty
              ? Image.network(avatarUrl!, fit: BoxFit.cover)
              : const CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Icon(Icons.person, size: 14, color: AppColors.outline),
                ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xxl),
                    topRight: Radius.circular(AppRadius.xxl),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(AppRadius.xxl),
                  ),
                ),
                child: Text(
                  message.content,
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.labelMd.copyWith(color: AppColors.outline),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  final MessageEntity message;
  const _OutgoingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xxl),
                  topRight: Radius.circular(AppRadius.xxl),
                  bottomLeft: Radius.circular(AppRadius.xxl),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.labelMd.copyWith(color: AppColors.outline),
              ),
              const SizedBox(width: 4),
              Icon(
                message.isRead ? Icons.done_all : Icons.done,
                size: 14,
                color: message.isRead ? AppColors.primary : AppColors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface.withValues(alpha: 0.85),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 28),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: TextField(
                    controller: controller,
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.outlineVariant,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: AppColors.onPrimary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


