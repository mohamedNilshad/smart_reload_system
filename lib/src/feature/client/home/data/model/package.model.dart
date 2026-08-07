import 'package:equatable/equatable.dart';

class PackageModel extends Equatable {
  final String? id;
  final String telecomType;
  final String serviceProvider;
  final String packageType;
  final String packageName;
  final String packageDescription;
  final double packagePrice;
  final double packageValidity;
  final String validityPeriod;

  const PackageModel({
    this.id,
    required this.telecomType,
    required this.serviceProvider,
    required this.packageType,
    required this.packageName,
    required this.packageDescription,
    required this.packagePrice,
    required this.packageValidity,
    required this.validityPeriod,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return PackageModel(
      id: id,
      telecomType: json['telecomType'] as String,
      serviceProvider: json['serviceProvider'] as String,
      packageType: json['packageType'] as String,
      packageName: json['packageName'] as String,
      packageDescription: json['packageDescription'] as String,
      packagePrice: json['packagePrice'] as double,
      packageValidity: json['packageValidity'] as double,
      validityPeriod: json['validityPeriod'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telecomType': telecomType,
      'serviceProvider': serviceProvider,
      'packageType': packageType,
      'packageName': packageName,
      'packageDescription': packageDescription,
      'packagePrice': packagePrice,
      'packageValidity': packageValidity,
      'validityPeriod': validityPeriod,
    };
  }

  @override
  List<Object?> get props => [
    id,
    telecomType,
    serviceProvider,
    packageType,
    packageName,
    packageDescription,
    packagePrice,
    packageValidity,
    validityPeriod,
  ];
}
