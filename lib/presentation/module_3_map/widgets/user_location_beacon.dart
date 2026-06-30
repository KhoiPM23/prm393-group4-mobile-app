import 'package:flutter/material.dart';

class UserLocationBeacon extends StatefulWidget {
  const UserLocationBeacon({super.key});
  @override
  State<UserLocationBeacon> createState() => UserLocationBeaconState();
}

class UserLocationBeaconState extends State<UserLocationBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Vòng sóng lan tỏa (Dùng CustomPainter để tránh build lại Widget)
            CustomPaint(
              size: const Size(36, 36),
              painter: _BeaconPainter(animation: _ctrl),
            ),
            // Vòng nền mờ tĩnh
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.20),
              ),
            ),
            // Chấm xanh trung tâm — viền trắng rõ nét tĩnh
            Container(
              width: 13,
              height: 13,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.shade600,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
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

class _BeaconPainter extends CustomPainter {
  final Animation<double> animation;

  _BeaconPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOut.transform(animation.value);
    
    // Scale goes from 0.5 to 1.0
    final scale = 0.5 + (0.5 * t);
    
    // Opacity goes from 0.6 to 0.0
    final opacity = 0.6 * (1.0 - t);
    
    final paint = Paint()
      ..color = Colors.blue.shade400.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 / scale; // Đảm bảo độ dày viền không đổi khi scale

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.drawCircle(Offset.zero, 18, paint); // 18 is half of 36 width
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BeaconPainter oldDelegate) => true;
}
