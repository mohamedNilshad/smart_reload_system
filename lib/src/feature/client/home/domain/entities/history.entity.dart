
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'history.entity.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class History extends Equatable{
  final String title;
  final String value;
  final String? type;
  final DateTime date;
  final String bgColor;

  const History({
    required this.title,
    required this.value,
    required this.type,
    required this.date,
    required this.bgColor,
  });


  factory History.fromJson(Map<String, dynamic> json) => _$HistoryFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryToJson(this);

  @override
  List<Object?> get props => [
    title,
    value,
    type,
    date,
    bgColor,
  ];
}