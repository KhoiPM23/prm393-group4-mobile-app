import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';

/// Màn hình Chat với Chủ nhà VibeLocals
/// Route: /chat
/// Source: tr_chuy_n_v_i_ch_nh_vibelocals/code.html
/// Design:
///   - Glassmorphic AppBar (back + avatar + online status + host name + more)
///   - Scrollable chat area (incoming = left, outgoing = right)
///   - Date divider "Hôm nay"
///   - Read receipts (done_all icon)
///   - Fixed bottom input bar (add + text field + emoji + send)
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          'Chào bạn! Tôi là Minh Khôi. Cảm ơn bạn đã đặt phòng tại VibeLocals. Tôi có thể giúp gì cho bạn không?',
      isOutgoing: false,
      time: '14:20',
      isRead: true,
    ),
    _ChatMessage(
      text:
          'Chào Minh Khôi, mình muốn hỏi về việc check-in. Nhà mình có thể nhận phòng sớm được không ạ?',
      isOutgoing: true,
      time: '14:22',
      isRead: true,
    ),
    _ChatMessage(
      text:
          'Dạ được chứ! Hiện tại phòng đang trống nên bạn có thể check-in sớm từ lúc 12:00 nhé.',
      isOutgoing: false,
      time: '14:23',
      isRead: true,
    ),
    _ChatMessage(
      text:
          'Tôi sẽ chuẩn bị trà và một ít bánh đặc sản địa phương để chào đón bạn.',
      isOutgoing: false,
      time: '14:24',
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isOutgoing: true,
        time:
            '${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}',
        isRead: false,
      ));
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ===== TOP APP BAR =====
          _ChatAppBar(
            onBackTap: () => Navigator.of(context).pop(),
          ),
          // ===== CHAT MESSAGES =====
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              itemCount: _messages.length + 1, // +1 for date divider
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _DateDivider(label: 'Hôm nay');
                }
                final msg = _messages[index - 1];
                return msg.isOutgoing
                    ? _OutgoingBubble(message: msg)
                    : _IncomingBubble(message: msg);
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
  final VoidCallback? onBackTap;
  const _ChatAppBar({this.onBackTap});

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
              // Back button
              IconButton(
                onPressed: onBackTap,
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.onSurface),
                style: IconButton.styleFrom(
                  minimumSize: const Size(
                      AppTouchTarget.minSize, AppTouchTarget.minSize),
                ),
              ),
              const SizedBox(width: 4),
              // Host avatar with online indicator
              Stack(
                children: [
                  ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBwozORqRy0O4Jg0TBxrG_D6N3cIOgy3QVCi5nqyUsrlCrldx4OJuoP7vcVwlRvyD1iY4DBw79n7YMUFxdMll8ADpkbvnWLG2hQFRoHyaix7uQttYYfeJG27-RsDGfpo3bFFpKikKR0HCMg2a8xSD9vg1BfEwCuGUxtMWsOWaoOKV2xaCAfAt1Gm_94HhQ7i6_NIaXirssgN6s4ww9LrGBpOkOsr7QvRpDWqcjyWJq6xCiifR8U9_9qJ9n2_jEoxxFF9lMgKz42wG0',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const CircleAvatar(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: Icon(Icons.person,
                              color: AppColors.outline),
                        ),
                      ),
                    ),
                  ),
                  // Online dot
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm),
              // Name + status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Minh Khôi',
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
              // More options
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert,
                    color: AppColors.onSurface),
                style: IconButton.styleFrom(
                  minimumSize: const Size(
                      AppTouchTarget.minSize, AppTouchTarget.minSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String label;
  const _DateDivider({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final _ChatMessage message;
  const _IncomingBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipOval(
          child: SizedBox(
            width: 30,
            height: 30,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB31srvyfCmUUyXUd13Uq1CEPEb-st5fMEWopn4Dda6qZs9-F01ZV-r6qAzR1Z3tyKDNPQnIL01VFSSz4VHycMhhl6WbX6Dm6jO-cO2BR7Cz-lo5iWBerNdKv_gUI-sCXem6vGa3EVlcrjhmoosgA2TAKDoULJVuLjVVc8o-zSvxFAZas9-M7fnY82IAT0R5Ok-HS_ivQnPivSOW-XMsCndHZ2I7Lg5ZNO9n_zve1IdbPCoEUi--r9SirjRufh3EarTBbLpqK_b_uw',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.surfaceContainerHigh,
                child: Icon(Icons.person, size: 14,
                    color: AppColors.outline),
              ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  message.text,
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.onSurface),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                message.time,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.outline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  final _ChatMessage message;
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
                message.text,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.onPrimary),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.time,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.outline,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                message.isRead
                    ? Icons.done_all
                    : Icons.done,
                size: 14,
                color: message.isRead
                    ? AppColors.primary
                    : AppColors.outline,
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
              // Add button
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 28),
                style: IconButton.styleFrom(
                  minimumSize: const Size(
                      AppTouchTarget.minSize, AppTouchTarget.minSize),
                ),
              ),
              // Text Input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.outlineVariant,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8),
                          ),
                          onSubmitted: (_) => onSend(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.sentiment_satisfied_outlined,
                          color: AppColors.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Send button
              GestureDetector(
                onTap: onSend,
                child: Container(
                  width: AppTouchTarget.minSize,
                  height: AppTouchTarget.minSize,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000666),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.send,
                      color: AppColors.onPrimary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text, time;
  final bool isOutgoing, isRead;
  const _ChatMessage({
    required this.text,
    required this.isOutgoing,
    required this.time,
    required this.isRead,
  });
}
