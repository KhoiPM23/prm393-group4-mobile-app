/// VibeLocals Spacing & Layout Constants
/// Source: stitch_vibelocals_flutter_property_screen/vibelocals_core/DESIGN.md
class AppSpacing {
  AppSpacing._();

  /// Base unit: 8px
  static const double unit = 8.0;
  static const double containerMarginMobile = 16.0;
  static const double containerMarginDesktop = 64.0;
  static const double gutter = 16.0;
  static const double sectionGap = 48.0;

  // Derived spacing values
  static const double xs = 4.0;   // unit * 0.5
  static const double sm = 8.0;   // unit * 1
  static const double md = 16.0;  // unit * 2
  static const double lg = 24.0;  // unit * 3
  static const double xl = 32.0;  // unit * 4
  static const double xxl = 48.0; // unit * 6 = sectionGap
}

/// VibeLocals Border Radius Constants
class AppRadius {
  AppRadius._();

  static const double sm = 4.0;    // 0.25rem
  static const double md = 8.0;    // 0.5rem
  static const double lg = 12.0;   // 0.75rem
  static const double xl = 16.0;   // 1rem - Standard elements
  static const double xxl = 24.0;  // 1.5rem - Large containers
  static const double full = 9999.0;

  // Specific semantic usage
  static const double button = 16.0;
  static const double card = 24.0;
  static const double input = 12.0;
  static const double chip = 8.0;
  static const double searchBar = 9999.0;
}

/// Touch target minimum size (Material Design 3 standard)
class AppTouchTarget {
  AppTouchTarget._();

  static const double minSize = 48.0;
}
