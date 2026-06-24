import 'package:flutter/material.dart';

class UserLocationBeacon extends StatefulWidget {
  const UserLocationBeacon({super.key});
  @override
  State<UserLocationBeacon> createState() => UserLocationBeaconState();
}

class UserLocationBeaconState extends State<UserLocationBeacon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _ringScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ringOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng sóng lan tỏa
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _ringOpacity.value,
              child: Transform.scale(
                scale: _ringScale.value,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue.shade400,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Vòng nền mờ
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.20),
            ),
          ),
          // Chấm xanh trung tâm — viền trắng rõ nét
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
    );
  }
}

