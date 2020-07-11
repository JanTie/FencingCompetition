import 'dart:async';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/db_provider.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';
import 'package:fencing_competition/model/result.dart';
import 'package:rxdart/rxdart.dart';

class MatchBloc extends BlocBase {
  int _competitionId;

  final StreamController<List<Match>> _unfinishedMatchesController =
  BehaviorSubject<List<Match>>();

  Stream<List<Match>> get unfinishedMatches =>
      _unfinishedMatchesController.stream.asBroadcastStream();

  final StreamController<List<Match>> _finishedMatchesController =
  BehaviorSubject<List<Match>>();

  Stream<List<Match>> get finishedMatches =>
      _finishedMatchesController.stream.asBroadcastStream();

  final StreamController _competitorsController =
  BehaviorSubject<List<Competitor>>();

  Stream<List<Competitor>> get competitors =>
      _competitorsController.stream.asBroadcastStream();

  Stream<MapEntry<List<Competitor>,
      List<Match>>> get competitorsAndUnfinishedMatches =>
      CombineLatestStream.combine2(
          competitors, unfinishedMatches, (a, b) => MapEntry(a, b));

  Stream<List<Result>> get results =>
      CombineLatestStream.combine2(
          competitors, finishedMatches, (List<Competitor> competitors,
          List<Match> matches) {
        if (competitors == null || matches == null || competitors.isEmpty ||
            matches.isEmpty) {
          return competitors.map((competitor) =>
              Result(competitor.name, 0, 0, 0)).toList();
        }

        final List<Result> results = competitors.map((competitor) {
          int wins = matches
              .where((match) => match.winner == competitor.id)
              .length;
          int points = matches.map((match) {
            if (match.winner == competitor.id) {
              return match.winnerPoints;
            } else if (match.homeCompetitor == competitor.id ||
                match.awayCompetitor == competitor.id) {
              return match.loserPoints;
            } else {
              return 0;
            }
          }).reduce((a, b) => a + b);
          int pointsTaken = matches.map((match) {
            if (match.winner == competitor.id) {
              return match.loserPoints;
            } else if (match.homeCompetitor == competitor.id ||
                match.awayCompetitor == competitor.id) {
              return match.winnerPoints;
            } else {
              return 0;
            }
          }).reduce((a, b) => a + b);
          return Result(competitor.name, wins, points, pointsTaken);
        }).toList();

        ///sort list according to fencing rules
        ///wins(index) -> pointIndex -> points scored
        results.sort((r1, r2) {
          if (r2.victoryCount != r1.victoryCount) {
            return r2.victoryCount.compareTo(r1.victoryCount);
          } else if (r2.pointIndex != r1.pointIndex) {
            return r2.pointIndex.compareTo(r1.pointIndex);
          } else {
            return r2.points.compareTo(r1.points);
          }
        });
        return results;
      });

  MatchBloc(this._competitionId) {
    getMatches();
    getCompetitors();
  }

  void getMatches() async {
    List<Match> matches =
    await DBProvider.db.findUnfinishedMatches(_competitionId);
    _unfinishedMatchesController.add(matches);
    List<Match> finishedMatches = await DBProvider.db.findFinishedMatches(
        _competitionId);
    _finishedMatchesController.add(finishedMatches);
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
    _unfinishedMatchesController.close();
    _finishedMatchesController.close();
    _competitorsController.close();
    super.dispose();
  }
}
