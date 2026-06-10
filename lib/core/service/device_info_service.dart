import 'dart:io';

class DeviceInfoService {
  static Future<String> getDeviceId() async {
    return 'device_${Platform.operatingSystem}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static Future<String> getDeviceName() async {
    return '${Platform.operatingSystem.toUpperCase()} Device';
  }

  static String getPlatform() {
    return Platform.operatingSystem;
  }
}
