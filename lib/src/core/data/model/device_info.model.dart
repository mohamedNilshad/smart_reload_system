
// {
// 'userId': userId, // Using deviceId as userId for this example
// 'deviceId': deviceId,
// 'deviceName': deviceName,
// 'deviceModel': deviceModel,
// 'osVersion': osVersion,
// 'fcmToken': token,
// 'platform': kIsWeb
// ? 'web'
//     : defaultTargetPlatform.name,
// };

import 'package:equatable/equatable.dart';

class DeviceInfoModel extends Equatable {
  final String userId;
  final String deviceId;
  final String deviceName;
  final String deviceModel;
  final String osVersion;
  final String fcmToken;
  final String platform;

  const DeviceInfoModel({
    required this.userId,
    required this.deviceId,
    required this.deviceName,
    required this.deviceModel,
    required this.osVersion,
    required this.fcmToken,
    required this.platform,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {
    return DeviceInfoModel(
      userId: json['userId'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
      deviceModel: json['deviceModel'] as String? ?? '',
      osVersion: json['osVersion'] as String? ?? '',
      fcmToken: json['fcmToken'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'fcmToken': fcmToken,
      'platform': platform,
    };
  }

  @override
  List<Object?> get props => [
    userId,
    deviceId,
    deviceName,
    deviceModel,
    osVersion,
    fcmToken,
    platform,
  ];
}