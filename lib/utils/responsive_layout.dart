import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth >= 1200) {
      return desktop;
    } else if (screenWidth >= 768) {
      return tablet ?? desktop;
    } else {
      return mobile;
    }
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1200;
  static const double desktop = 1200;
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < ResponsiveBreakpoints.mobile;
  bool get isTablet => MediaQuery.of(this).size.width >= ResponsiveBreakpoints.mobile && 
                      MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;
  bool get isDesktop => MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;
  
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.width;
}