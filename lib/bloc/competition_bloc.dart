
import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';

class CompetitionBloc extends BlocBase{

  final StreamController _competitionsController = StreamController<List<Competition>>();
  Stream<List<Competition>> get competitions => _competitionsController.stream;

  CompetitionBloc(){
    getCompetitions();
  }

  void getCompetitions() async {
    List<Competition> competitions = await DBProvider.db.findCompetitions();
    _competitionsController.add(competitions);
  }

  void addCompetition(Competition competition, List<Competitor> competitors) async{
    //insert competition
    final int competitionId = await DBProvider.db.insertCompetition(competition);
    //insert competitors
    final List<int> competitorIds = await DBProvider.db.insertCompetitors(competitionId, competitors);
    //generate matches
    await _generateMatches(competitionId, competitorIds);

    //reload competitions
    getCompetitions();
  }

  ///generates the matches for the given competition and its competitors
  Future<List<int>> _generateMatches(int competitionId, List<int> competitorIds) async {
      //in case the amount of competitors is odd, add a dummy entry
      if (competitorIds.length % 2 == 1) {
        competitorIds.add(null);
      }
      final List<Match> matches = [];
      for (var rotationIndex = 0;
      rotationIndex < competitorIds.length;
      rotationIndex++) {
        for (var index = 0; index < competitorIds.length / 2; index++) {
          final home = competitorIds[index];
          final away = competitorIds[competitorIds.length - 1 - index];
          //in case one of the competitors is a dummy entry, skip the match
          if (home == null || away == null) {
            continue;
          }
          matches.add(
            Match(
              competitionId: competitionId,
              homeCompetitor: home,
              awayCompetitor: away,
            ),
          );
        }
        competitorIds = _rotate(competitorIds, 1);
      }
      return DBProvider.db.insertMatches(matches);
  }

  /// Utility function that rotates a given list by v indices
  List<Object> _rotate(List<Object> list, int v) {
    if (list == null || list.isEmpty) return list;
    var i = v % list.length;
    return list.sublist(i)..addAll(list.sublist(0, i));
  }

  @override
  void dispose() {
    _competitionsController.close();
    super.dispose();
  }
}