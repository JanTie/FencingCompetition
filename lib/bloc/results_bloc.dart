import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';

class ResultsBloc extends BlocBase {
  int _competitionId;

  final StreamController _matchesController = StreamController<List<Match>>();

  Stream<List<Match>> get results => _matchesController.stream;

  final StreamController _competitorsController =
      StreamController<List<Competitor>>();

  Stream<List<Competitor>> get competitors => _competitorsController.stream;

  ResultsBloc(this._competitionId) {
    getMatches();
    getCompetitors();
  }

  void getMatches() async {
    List<Match> matches = await DBProvider.db.findMatches(_competitionId);
    _matchesController.add(matches);
  }

  void getCompetitors() async {
    List<Competitor> competitors =
        await DBProvider.db.findCompetitors(_competitionId);
    _competitorsController.add(competitors);
  }

  @override
  void dispose() {
    _matchesController.close();
    _competitorsController.close();
    super.dispose();
  }
}
