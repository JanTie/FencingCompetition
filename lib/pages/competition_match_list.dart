import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/match_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';
import 'package:fencing_competition/model/result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        body: BlocProvider(
          blocs: [Bloc((_) => MatchBloc(competition.id))],
          child: TabBarView(
            children: [
              MatchesList(),
              ResultsList(),
            ],
          ),
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
    showDialog(
        context: context,
        builder: (context) {
          _homeController.text = "";
          _awayController.text = "";
          return AlertDialog(
            title: Text(AppLocalizations.of(context)
                .translate('matches_result_dialog_title')),
            content: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          "${home.name} ${AppLocalizations.of(context).translate('matches_result_dialog_points')}",
                    ),
                    controller: _homeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText:
                          "${away.name} ${AppLocalizations.of(context).translate('matches_result_dialog_points')}",
                    ),
                    controller: _awayController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  RaisedButton(
                    child: Text(AppLocalizations.of(context)
                        .translate('matches_result_dialog_save')),
                    onPressed: () {
                      try {
                        final homeScore = int.parse(_homeController.text);
                        final awayScore = int.parse(_awayController.text);
                        match
                          ..winnerPoints = max(homeScore, awayScore)
                          ..loserPoints = min(homeScore, awayScore)
                          //TODO add priority
                          ..winner = homeScore >= awayScore ? home.id : away.id;
                        BlocProvider.getBloc<MatchBloc>().updateMatch(match);
                        Navigator.pop(context);
                      } catch (_) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context).translate(
                                  'matches_result_dialog_error_snackbar'),
                            ),
                          ),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<MapEntry<List<Competitor>, List<Match>>>(
        stream:
            BlocProvider.getBloc<MatchBloc>().competitorsAndUnfinishedMatches,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Competitor> competitors = snapshot.data.key;
            final List<Match> matches = snapshot.data.value;
            if(matches.isNotEmpty) {
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
                                    Text(AppLocalizations.of(context).translate(
                                        'matches_list_horizontal_divider'),),
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
              return Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(AppLocalizations.of(context).translate(
                      'matches_list_empty_state'),),
                ),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      );
}

class ResultsList extends StatefulWidget {
  @override
  State createState() => _ResultsListState();
}

class _ResultsListState extends State<ResultsList> {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Result>>(
        stream: BlocProvider.getBloc<MatchBloc>().results,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Result> results = snapshot.data;
            return DataTable(
              columns: [
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)
                        .translate('matches_result_table_name'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)
                        .translate('matches_result_table_wins'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)
                        .translate('matches_result_table_points'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)
                        .translate('matches_result_table_points_retrieved'),
                  ),
                ),
                DataColumn(
                  label: Text(
                    AppLocalizations.of(context)
                        .translate('matches_result_table_points_difference'),
                  ),
                ),
              ],
              rows: results
                  .map((result) => DataRow(cells: [
                        DataCell(Text(result.competitorName)),
                        DataCell(Text(result.victoryCount.toString())),
                        DataCell(Text(result.points.toString())),
                        DataCell(Text(result.pointsTaken.toString())),
                        DataCell(Text(result.pointIndex.toString())),
                      ]))
                  .toList(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
}
