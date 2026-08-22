import 'package:screen_protector/screen_protector.dart';

abstract final class ScreenCaptureProtection {
  static Future<void> enable() => ScreenProtector.preventScreenshotOn();

  static Future<void> disable() => ScreenProtector.preventScreenshotOff();
}
