import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/match_bloc.dart';
import 'package:fencing_competition/bloc/results_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';
import 'package:flutter/material.dart';

class CompetitionMatchList extends StatefulWidget {
  static const NAVIGATION_KEY = "/competition/matches";

  @override
  State createState() => _CompetitionMatchListState();
}

class _CompetitionMatchListState extends State<CompetitionMatchList> {
  @override
  Widget build(BuildContext context) {
    final Competition competition = ModalRoute.of(context).settings.arguments;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(competition.name),
          bottom: TabBar(
            tabs: [
              Tab(
                text: AppLocalizations.of(context)
                    .translate('matches_tab_matches'),
              ),
              Tab(
                text: AppLocalizations.of(context)
                    .translate('matches_tab_results'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              blocs: [Bloc((_) => MatchBloc(competition.id))],
              child: MatchesList(),
            ),
            BlocProvider(
              blocs: [Bloc((_) => ResultsBloc(competition.id))],
              child: ResultsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesList extends StatefulWidget {
  @override
  State createState() => _MatchesListState();
}

class _MatchesListState extends State<MatchesList> {
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();

  void buildDialog(
      BuildContext context, Match match, Competitor home, Competitor away) {
    print(match.winner);
    showDialog(
        context: context,
        builder: (context) {
          _homeController.text = "";
          _awayController.text = "";
          return Dialog(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _homeController,
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _awayController,
                    keyboardType: TextInputType.number,
                  ),
                  MaterialButton(
                    child: Text(AppLocalizations.of(context)
                        .translate('matches_result_save')),
                    onPressed: () {
                      final homeScore = int.parse(_homeController.text);
                      final awayScore = int.parse(_awayController.text);
                      match
                        ..winnerPoints = max(homeScore, awayScore)
                        ..loserPoints = min(homeScore, awayScore)
                        //TODO add priority
                        ..winner = homeScore >= awayScore ? home.id : away.id;
                      BlocProvider.getBloc<MatchBloc>().updateMatch(match);
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Competitor>>(
      stream: BlocProvider.getBloc<MatchBloc>().competitors,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final List<Competitor> competitors = snapshot.data;
          return StreamBuilder<List<Match>>(
            stream: BlocProvider.getBloc<MatchBloc>().matches,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final List<Match> matches = snapshot.data;

                return ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      final home = competitors.firstWhere(
                          (element) => element.id == match.homeCompetitor);
                      final away = competitors.firstWhere(
                          (element) => element.id == match.awayCompetitor);
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              buildDialog(context, match, home, away);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(home.name),
                                      Text("vs."),
                                      Text(away.name),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    });
              } else {
                return CircularProgressIndicator();
              }
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      });
}

class ResultsList extends StatefulWidget {
  @override
  State createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Match>>(
        stream: BlocProvider.getBloc<ResultsBloc>().results,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Match> matches = snapshot.data;

            return Container();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
}
