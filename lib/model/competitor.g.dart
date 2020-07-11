// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competitor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Competitor _$CompetitorFromJson(Map<String, dynamic> json) {
  return Competitor(
    id: json['id'] as int,
    name: json['name'] as String,
    competitionId: json['competitionId'] as int,
  );
}

Map<String, dynamic> _$CompetitorToJson(Competitor instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'competitionId': instance.competitionId,
    };
