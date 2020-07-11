import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/match.dart';

class MatchBloc extends BlocBase{
  int _competitionId;

  final StreamController _matchesController = StreamController<List<Match>>();
  Stream<List<Match>> get matches => _matchesController.stream;

  MatchBloc(this._competitionId){
    getMatches();
  }

  void getMatches() async {
    List<Match> matches = await DBProvider.db.findMatches(_competitionId);
    _matchesController.add(matches);
  }

  @override
  void dispose() {
    _matchesController.close();
    super.dispose();
  }
}