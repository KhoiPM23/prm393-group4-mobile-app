import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/property_entity.dart';

class PropertyPreviewCard extends StatefulWidget {
  final PropertyEntity property;
  final String distance;
  final Widget actionButton;
  final Widget? secondaryActionButton;

  const PropertyPreviewCard({super.key, 
      required this.property,
      required this.distance,
      required this.actionButton,
      this.secondaryActionButton});

  @override
  State<PropertyPreviewCard> createState() => PropertyPreviewCardState();
}

class PropertyPreviewCardState extends State<PropertyPreviewCard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Hero(
                  tag: 'property-image-${widget.property.id}',
                  child: SizedBox(
                    width: double.infinity,
                    height: 145,
                    child: widget.property.imageUrls.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            onPageChanged: (idx) =>
                                setState(() => _currentPage = idx),
                            itemCount: widget.property.imageUrls.length,
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: widget.property.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    color: Colors.grey.shade200,
                                ),
                                errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade100,
                                    child: const Icon(Icons.villa,
                                        color: Colors.grey)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.villa, color: Colors.grey)),
                  ),
                ),
                // Premium dots indicator
                if (widget.property.imageUrls.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.property.imageUrls.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: _currentPage == index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _FavoriteButton(propertyId: widget.property.id),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(widget.property.title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 6),
                    Row(children: [
                      const Icon(Icons.star, size: 14, color: Colors.black),
                      const SizedBox(width: 2),
                      Text(widget.property.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black))
                    ]),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                    '${widget.property.district}, ${widget.property.city} • Cách ${widget.distance}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(children: [
                          TextSpan(
                              text:
                                  'Từ ${(widget.property.pricePerNight).toStringAsFixed(0).replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]}.")}đ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 14)),
                          TextSpan(
                              text: ' /đêm',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 12)),
                        ]),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.secondaryActionButton != null) ...[
                          widget.secondaryActionButton!,
                          const SizedBox(width: 6),
                        ],
                        widget.actionButton,
                      ],
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

class _FavoriteButton extends StatefulWidget {
  final String propertyId;
  const _FavoriteButton({required this.propertyId});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // TweenSequence tạo hiệu ứng: phình to → nảy lại → ổn định
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.90), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact(); // Thêm rung phản hồi
        setState(() => _isFavorite = !_isFavorite);
        _bounceCtrl.forward(from: 0); // Trigger mỗi lần tap
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hiệu ứng pháo hoa bắn ra (6 chấm đỏ mờ dần)
          ...List.generate(6, (index) {
            final angle = (index * 60) * math.pi / 180;
            return AnimatedBuilder(
              animation: _bounceCtrl,
              builder: (context, child) {
                final progress = _bounceCtrl.value;
                final distance = progress * 24.0;
                final opacity = 1.0 - progress;
                if (!_isFavorite || progress == 0.0 || progress == 1.0) {
                  return const SizedBox.shrink();
                }
                return Transform.translate(
                  offset: Offset(
                      math.cos(angle) * distance, math.sin(angle) * distance),
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          ScaleTransition(
            scale: _scaleAnim,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // AnimatedSwitcher tạo cross-fade icon khi toggle
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(
                      _isFavorite), // Quan trọng: key khác nhau mới trigger switcher
                  color: _isFavorite ? Colors.red.shade400 : Colors.black54,
                  size: 18,
                ),
              ), // AnimatedSwitcher
            ), // Container
          ), // ScaleTransition
        ],
      ),
    );
  }
}

