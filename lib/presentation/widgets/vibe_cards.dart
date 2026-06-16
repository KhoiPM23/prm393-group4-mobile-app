import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';

/// Room Card Widget
/// Used in PropertyDetailScreen - shows room image, name, price, amenities
class RoomCard extends StatelessWidget {
  final String name;
  final String priceText;
  final String imageUrl;
  final bool isAvailable;
  final String bedType;
  final String area;
  final String amenity;
  final VoidCallback? onTap;

  const RoomCard({
    super.key,
    required this.name,
    required this.priceText,
    required this.imageUrl,
    this.isAvailable = true,
    required this.bedType,
    required this.area,
    required this.amenity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Image with Availability Badge
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceContainerHigh,
                      child: const Icon(Icons.bed_outlined,
                          size: 48, color: AppColors.outline),
                    ),
                  ),
                  // Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.tertiaryFixed
                            : AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        isAvailable ? 'Còn phòng' : 'Hết phòng',
                        style: AppTextStyles.labelMd.copyWith(
                          color: isAvailable
                              ? AppColors.onTertiaryFixed
                              : AppColors.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Room Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleLg
                        .copyWith(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: priceText,
                          style: AppTextStyles.titleLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: '/đêm',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.outline,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Amenities row
                  Row(
                    children: [
                      _AmenityIcon(
                          icon: Icons.bed_outlined, label: bedType),
                      const SizedBox(width: AppSpacing.md),
                      _AmenityIcon(
                          icon: Icons.square_foot_outlined, label: area),
                      const SizedBox(width: AppSpacing.md),
                      _AmenityIcon(
                          icon: Icons.wifi_outlined, label: amenity),
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
}

class _AmenityIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelMd
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Notification Item Card
/// Used in NotificationCenterScreen
class NotificationItemCard extends StatefulWidget {
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationItemCard({
    super.key,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isUnread = false,
    this.onTap,
  });

  @override
  State<NotificationItemCard> createState() =>
      _NotificationItemCardState();
}

class _NotificationItemCardState extends State<NotificationItemCard> {
  late bool _isUnread;

  @override
  void initState() {
    super.initState();
    _isUnread = widget.isUnread;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isUnread = false);
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _isUnread
              ? AppColors.surfaceContainerLowest
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: _isUnread
                ? AppColors.outlineVariant.withValues(alpha: 0.2)
                : AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
          boxShadow: _isUnread
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon,
                  color: widget.iconColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: _isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        widget.timeAgo,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.body,
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Unread indicator dot
            if (_isUnread)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
