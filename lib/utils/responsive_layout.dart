import 'package:flutter/material.dart';

/// Merkezi breakpoint ve responsive yardımcıları.
/// Kullanım örnekleri:
/// if (Responsive.isMd(context)) ...;
/// final columns = Responsive.columnsFor(context, {Breakpoints.xs: 1, Breakpoints.sm: 2, Breakpoints.md: 3, Breakpoints.lg: 4});
class Responsive {
  static const double xs = 0;       // <600
  static const double sm = 600;     // >=600 <840
  static const double md = 840;     // >=840 <1200
  static const double lg = 1200;    // >=1200 <1600
  static const double xl = 1600;    // >=1600

  static Breakpoint ofSize(double width) {
    if (width >= xl) return Breakpoint.xl;
    if (width >= lg) return Breakpoint.lg;
    if (width >= md) return Breakpoint.md;
    if (width >= sm) return Breakpoint.sm;
    return Breakpoint.xs;
  }

  static Breakpoint of(BuildContext context) => ofSize(MediaQuery.of(context).size.width);

  static bool isXs(BuildContext c) => of(c) == Breakpoint.xs;
  static bool isSm(BuildContext c) => of(c) == Breakpoint.sm;
  static bool isMd(BuildContext c) => of(c) == Breakpoint.md;
  static bool isLg(BuildContext c) => of(c) == Breakpoint.lg;
  static bool isXl(BuildContext c) => of(c) == Breakpoint.xl;

  /// Breakpoint’e göre sütun sayısı döndür.
  static int columnsFor(BuildContext c, Map<Breakpoint, int> map, {int fallback = 1}) {
    final bp = of(c);
    return map[bp] ??
        map[Breakpoint.md] ??
        map[Breakpoint.sm] ??
        map[Breakpoint.lg] ??
        map[Breakpoint.xs] ??
        fallback;
  }

  /// Breakpoint’e göre spacing döndür.
  static double spacingFor(BuildContext c, {double xsVal = 8, double smVal = 12, double mdVal = 16, double lgVal = 20, double xlVal = 24}) {
    switch (of(c)) {
      case Breakpoint.xs:
        return xsVal;
      case Breakpoint.sm:
        return smVal;
      case Breakpoint.md:
        return mdVal;
      case Breakpoint.lg:
        return lgVal;
      case Breakpoint.xl:
        return xlVal;
    }
  }

  /// GridDelegate yardımcıları
  static SliverGridDelegateWithFixedCrossAxisCount gridFor(BuildContext c, {required Map<Breakpoint, int> columns, double childAspectRatio = 1.4, double mainSpacing = 12, double crossSpacing = 12}) {
    final count = columnsFor(c, columns);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
      childAspectRatio: childAspectRatio,
      mainAxisSpacing: mainSpacing,
      crossAxisSpacing: crossSpacing,
    );
  }
}

enum Breakpoint { xs, sm, md, lg, xl }

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
  double get screenHeight => MediaQuery.of(this).size.height;
}
