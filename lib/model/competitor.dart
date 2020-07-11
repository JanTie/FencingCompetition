import 'package:json_annotation/json_annotation.dart';

part 'competitor.g.dart';

@JsonSerializable()
class Competitor {
  int id;
  String name;
  int competitionId;

  Competitor({this.id, this.name, this.competitionId});

  factory Competitor.fromJson(Map<String, dynamic> json) =>
      _$CompetitorFromJson(json);

  Map<String, dynamic> toJson() => _$CompetitorToJson(this);
}
