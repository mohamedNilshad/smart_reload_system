// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

History _$HistoryFromJson(Map<String, dynamic> json) => History(
      title: json['title'] as String,
      value: json['value'] as String,
      type: json['type'] as String?,
      date: DateTime.parse(json['date'] as String),
      bgColor: json['bgColor'] as String,
    );

Map<String, dynamic> _$HistoryToJson(History instance) => <String, dynamic>{
      'title': instance.title,
      'value': instance.value,
      'type': instance.type,
      'date': instance.date.toIso8601String(),
      'bgColor': instance.bgColor,
    };
