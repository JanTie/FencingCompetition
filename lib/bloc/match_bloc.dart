import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';

class MatchBloc extends BlocBase {
  int _competitionId;

  final StreamController<List<Match>> _matchesController =
      StreamController<List<Match>>();

  Stream<List<Match>> get matches => _matchesController.stream;

  Stream get results => _matchesController.stream.map((event) {
        return event.where((element) => element.winner != null);
      });

  final StreamController _competitorsController =
      StreamController<List<Competitor>>();

  Stream<List<Competitor>> get competitors => _competitorsController.stream;

  MatchBloc(this._competitionId) {
    getMatches();
    getCompetitors();
  }

  void getMatches() async {
    List<Match> matches =
        await DBProvider.db.findUnfinishedMatches(_competitionId);
    _matchesController.add(matches);
  }

  void getCompetitors() async {
    List<Competitor> competitors =
        await DBProvider.db.findCompetitors(_competitionId);
    _competitorsController.add(competitors);
  }

  void updateMatch(Match match) async {
    await DBProvider.db.insertMatch(match);
    getMatches();
  }

  @override
  void dispose() {
    _matchesController.close();
    _competitorsController.close();
    super.dispose();
  }
}
