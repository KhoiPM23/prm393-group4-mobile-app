import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapScaleBar extends StatefulWidget {
  final MapController mapController;
  const MapScaleBar({super.key, required this.mapController});

  @override
  State<MapScaleBar> createState() => _MapScaleBarState();
}

class _MapScaleBarState extends State<MapScaleBar> {
  double _distance = 500;
  String _unit = 'm';
  double _barWidth = 50;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.mapController.mapEventStream.listen((_) {
      _updateScale();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScale();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  void _updateScale() {
    if (!mounted) return;
    try {
      final zoom = widget.mapController.camera.zoom;
      final metersPerPixel = 156543.03392 *
          math.cos(
              widget.mapController.camera.center.latitude * math.pi / 180) /
          math.pow(2, zoom);

      final List<double> thresholds = [
        10,
        20,
        50,
        100,
        200,
        500,
        1000,
        2000,
        5000,
        10000,
        20000,
        50000
      ];
      double targetDist = thresholds.last;

      for (var t in thresholds) {
        if (t / metersPerPixel >= 45) {
          // Minimum 45px width visually
          targetDist = t;
          break;
        }
      }

      double calculatedWidth = targetDist / metersPerPixel;

      String newUnit = 'm';
      double displayDist = targetDist;
      if (targetDist >= 1000) {
        displayDist = targetDist / 1000;
        newUnit = 'km';
      }

      setState(() {
        _distance = displayDist;
        _unit = newUnit;
        _barWidth = calculatedWidth.clamp(40.0, 150.0);
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_distance == _distance.roundToDouble() ? _distance.toInt() : _distance} $_unit',
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _barWidth,
          height: 8,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black87, width: 2),
              left: BorderSide(color: Colors.black87, width: 2),
              right: BorderSide(color: Colors.black87, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
