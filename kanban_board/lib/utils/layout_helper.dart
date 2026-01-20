import 'package:flutter/material.dart';

class LayoutHelper {
  final BuildContext? context;

  LayoutHelper(this.context);

  double get screenWidth {
    if (context == null) return 0.0;
    try {
      return MediaQuery.of(context!).size.width;
    } catch (e) {
      return 0.0;
    }
  }

  double get screenHeight {
    if (context == null) return 0.0;
    try {
      return MediaQuery.of(context!).size.height;
    } catch (e) {
      return 0.0;
    }
  }

  double get devicePixelRatio {
    if (context == null) return 1.0;
    try {
      return MediaQuery.of(context!).devicePixelRatio;
    } catch (e) {
      return 1.0;
    }
  }

  Orientation get orientation {
    if (context == null) return Orientation.portrait;
    try {
      return MediaQuery.of(context!).orientation;
    } catch (e) {
      return Orientation.portrait;
    }
  }

  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;

  bool get isTablet => screenWidth >= 600;

  double get navigationBarPadding {
    if (context == null) return 0.0;
    try {
      final padding = MediaQuery.of(context!).viewPadding.bottom;

      return padding > 0 ? padding : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
