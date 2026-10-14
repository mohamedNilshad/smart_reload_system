import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceInfo(String userId, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // Generate an ID once per app installation.
    String? deviceId = await getDeviceId();

    String deviceName = 'Unknown';
    String deviceModel = 'Unknown';
    String osVersion = 'Unknown';

    if (kIsWeb) {
      final info = await _deviceInfo.webBrowserInfo;
      deviceName = info.browserName.name;
      osVersion = info.platform ?? 'Unknown';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final info = await _deviceInfo.androidInfo;
      deviceName = info.manufacturer;
      deviceModel = info.model;
      osVersion = info.version.release;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final info = await _deviceInfo.iosInfo;
      deviceName = info.name;
      deviceModel = info.model;
      osVersion = info.systemVersion;
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      final info = await _deviceInfo.windowsInfo;
      deviceName = info.computerName;
      osVersion = info.productName;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      final info = await _deviceInfo.macOsInfo;
      deviceName = info.computerName;
      deviceModel = info.model;
      osVersion = info.osRelease;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      final info = await _deviceInfo.linuxInfo;
      deviceName = info.name;
      osVersion = info.version ?? 'Unknown';
    }



    return {
      'userId': userId, // Using deviceId as userId for this example
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'fcmToken': token,
      'platform': kIsWeb
          ? 'web'
          : defaultTargetPlatform.name,
    };
  }

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('app_device_id');

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString('app_device_id', deviceId);
    }

    return deviceId;
  }
}