abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double medium = 1024;
  static const double large = 1440;

  static bool isMobile(double width) => width < compact;

  static bool isTablet(double width) {
    return width >= compact && width < medium;
  }

  static bool isDesktop(double width) => width >= medium;

  static bool isLargeDesktop(double width) => width >= large;
}