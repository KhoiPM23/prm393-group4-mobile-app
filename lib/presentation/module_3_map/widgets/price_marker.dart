import 'package:flutter/material.dart';

class PriceMarker extends StatefulWidget {
  final String price;
  final bool isActive;
  const PriceMarker({super.key, required this.price, required this.isActive});

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

    // Tạo độ trễ ngẫu nhiên nhẹ dựa vào hashCode của giá để các marker không hiện ra cùng lúc (Staggered Load)
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
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _spawnCtrl, curve: Curves.bounceOut)),
      child: FadeTransition(
        opacity: _spawnAnim,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: widget.isActive ? 1.15 : 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Radar Ripple Effect when Active
              if (widget.isActive)
                AnimatedBuilder(
                  animation: _rippleCtrl,
                  builder: (context, _) {
                    final val1 = _rippleCtrl.value;
                    final val2 = (val1 + 0.5) % 1.0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50 + (val1 * 50),
                          height: 30 + (val1 * 50),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withValues(alpha: (1 - val1) * 0.4),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        Container(
                          width: 50 + (val2 * 50),
                          height: 30 + (val2 * 50),
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withValues(alpha: (1 - val2) * 0.4),
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isActive ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: widget.isActive
                      ? Border.all(color: Colors.transparent, width: 1)
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
                child: Center(
                  child: Text(
                    widget.price,
                    style: TextStyle(
                      color: widget.isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isActive ? 14 : 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
