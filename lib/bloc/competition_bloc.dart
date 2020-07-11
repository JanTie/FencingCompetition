import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';

class CompetitionBloc extends BlocBase {
  final StreamController _competitionsController =
      StreamController<List<Competition>>();

  Stream<List<Competition>> get competitions =>
      _competitionsController.stream.asBroadcastStream();

  CompetitionBloc() {
    getCompetitions();
  }

  void getCompetitions() async {
    List<Competition> competitions = await DBProvider.db.findCompetitions();
    _competitionsController.add(competitions);
  }

  Future addCompetition(
      Competition competition, List<Competitor> competitors) async {
    //insert competition
    final int competitionId =
        await DBProvider.db.insertCompetition(competition);
    //insert competitors
    final List<int> competitorIds =
        await DBProvider.db.insertCompetitors(competitionId, competitors);
    //generate matches
    await _generateMatches(competitionId, competitorIds);

    //reload competitions
    getCompetitions();
  }

  ///generates the matches for the given competition and its competitors
  ///using the circle method: https://en.wikipedia.org/wiki/Round-robin_tournament#Circle_method
  Future<List<int>> _generateMatches(
      int competitionId, List<int> competitorIds) async {
    //in case the amount of competitors is odd, add a dummy entry
    if (competitorIds.length % 2 == 1) {
      competitorIds.add(null);
    }
    final List<Match> matches = [];
    for (var rotationIndex = 0;
        rotationIndex < competitorIds.length - 1;
        rotationIndex++) {
      print(competitorIds);
      for (var matchIndex = 0;
          matchIndex < competitorIds.length / 2;
          matchIndex++) {
        final home = competitorIds[matchIndex];
        final away = competitorIds[competitorIds.length - 1 - matchIndex];
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
      competitorIds = _rotateOne(competitorIds);
    }
    return DBProvider.db.insertMatches(matches);
  }

  /// Utility function that rotates a given list by v indices
  List<int> _rotateOne(List<int> list) {
    if (list == null || list.length <= 2) return list;
    return [list[0]]
      ..add(list[list.length - 1])
      ..addAll(list.sublist(1, list.length - 1));
  }

  @override
  void dispose() {
    _competitionsController.close();
    super.dispose();
  }
}
