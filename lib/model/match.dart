import 'package:json_annotation/json_annotation.dart';

part 'match.g.dart';

@JsonSerializable()
class Match {
  int id;
  int competitionId;
  int homeCompetitor;
  int awayCompetitor;
  int winner;
  int winnerPoints;
  int loserPoints;

  Match(
      {this.id,
      this.competitionId,
      this.homeCompetitor,
      this.awayCompetitor,
      this.winner,
      this.winnerPoints,
      this.loserPoints});

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
  Map<String, dynamic> toJson() => _$MatchToJson(this);
}
