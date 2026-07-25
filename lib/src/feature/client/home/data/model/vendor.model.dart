import 'package:equatable/equatable.dart';

class VendorModel extends Equatable {
  final String vendorId;
  final String vendorName;
  final int connectionCount;

  const VendorModel({
    required this.vendorId,
    required this.vendorName,
    required this.connectionCount,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      connectionCount: json['connectionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'vendorName': vendorName,
      'connectionCount': connectionCount,
    };
  }

  @override
  List<Object?> get props => [vendorId, vendorName, connectionCount];
}
