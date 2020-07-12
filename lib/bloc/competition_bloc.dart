import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:rxdart/rxdart.dart';

class CompetitionBloc extends BlocBase {
  final StreamController _competitionsController =
      BehaviorSubject<List<Competition>>();

  Stream<List<Competition>> get competitions =>
      _competitionsController.stream.asBroadcastStream();

  CompetitionBloc() {
    getCompetitions();
  }

  void getCompetitions() async {
    List<Competition> competitions = await DBProvider.db.findCompetitions();
    _competitionsController.add(competitions);
  }

  @override
  void dispose() {
    _competitionsController.close();
    super.dispose();
  }
}
