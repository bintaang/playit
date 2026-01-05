import 'package:flutter/material.dart';

extension ScreenSize on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  bool get isMobile => screenSize.shortestSide < 600;
  bool get isTablet => screenSize.shortestSide >= 600;
}
