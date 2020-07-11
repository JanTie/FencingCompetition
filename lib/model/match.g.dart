// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Match _$MatchFromJson(Map<String, dynamic> json) {
  return Match(
    id: json['id'] as int,
    competitionId: json['competitionId'] as int,
    homeCompetitor: json['homeCompetitor'] as int,
    awayCompetitor: json['awayCompetitor'] as int,
    winner: json['winner'] as int,
    winnerPoints: json['winnerPoints'] as int,
    loserPoints: json['loserPoints'] as int,
  );
}

Map<String, dynamic> _$MatchToJson(Match instance) => <String, dynamic>{
      'id': instance.id,
      'competitionId': instance.competitionId,
      'homeCompetitor': instance.homeCompetitor,
      'awayCompetitor': instance.awayCompetitor,
      'winner': instance.winner,
      'winnerPoints': instance.winnerPoints,
      'loserPoints': instance.loserPoints,
    };
