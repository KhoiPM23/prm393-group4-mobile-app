import 'package:flutter/material.dart';

class PriceMarker extends StatefulWidget {
  final String price;
  final bool isActive;
  final bool isFavorite;
  const PriceMarker({super.key, required this.price, required this.isActive, this.isFavorite = false});

  @override
  State<PriceMarker> createState() => _PriceMarkerState();
}

class _PriceMarkerState extends State<PriceMarker>
    with TickerProviderStateMixin {
  late final AnimationController _spawnCtrl;
  late final Animation<double> _spawnAnim;
  late final AnimationController _rippleCtrl;

  @override
  void initState() {
    super.initState();
    _spawnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _spawnAnim = CurvedAnimation(parent: _spawnCtrl, curve: Curves.elasticOut);

    _rippleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));
    if (widget.isActive) _rippleCtrl.repeat();

    // Tạo độ trễ ngẫu nhiên nhẹ để các marker không hiện ra cùng lúc (Staggered Load)
    Future.delayed(Duration(milliseconds: widget.price.hashCode % 400), () {
      if (mounted) _spawnCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(covariant PriceMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _rippleCtrl.repeat();
    } else if (!widget.isActive && oldWidget.isActive) {
      _rippleCtrl.stop();
      _rippleCtrl.reset();
    }
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _spawnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _spawnAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _spawnAnim.value * (widget.isActive ? 1.15 : 1.0),
            child: child,
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Radar Ripple Effect when Active
            if (widget.isActive)
              CustomPaint(
                size: const Size(100, 100),
                painter: _RipplePainter(animation: _rippleCtrl),
              ),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: widget.isActive ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: widget.isActive
                    ? null
                    : Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: widget.isActive
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.12),
                    blurRadius: widget.isActive ? 16 : 6,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.price,
                    style: TextStyle(
                      color: widget.isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isActive ? 14 : 13,
                    ),
                  ),
                  if (widget.isFavorite) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.favorite, color: Colors.red.shade400, size: 14),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;

  _RipplePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final val1 = animation.value;
    final val2 = (val1 + 0.5) % 1.0;

    final paint1 = Paint()
      ..color = Colors.black.withValues(alpha: (1 - val1) * 0.4)
      ..style = PaintingStyle.fill;
      
    final paint2 = Paint()
      ..color = Colors.black.withValues(alpha: (1 - val2) * 0.4)
      ..style = PaintingStyle.fill;

    final baseWidth = 50.0;
    final baseHeight = 30.0;

    final rRect1 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: baseWidth * (1.0 + val1),
        height: baseHeight * (1.0 + val1),
      ),
      const Radius.circular(40),
    );

    final rRect2 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: baseWidth * (1.0 + val2),
        height: baseHeight * (1.0 + val2),
      ),
      const Radius.circular(40),
    );

    canvas.drawRRect(rRect1, paint1);
    canvas.drawRRect(rRect2, paint2);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => true;
}
