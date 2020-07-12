import 'dart:math';

import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/match_bloc.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/model/match.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatchesList extends StatefulWidget {
  @override
  State createState() => _MatchesListState();
}

class _MatchesListState extends State<MatchesList> {
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<MapEntry<List<Competitor>, List<Match>>>(
        stream:
            BlocProvider.getBloc<MatchBloc>().competitorsAndUnfinishedMatches,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Competitor> competitors = snapshot.data.key;
            final List<Match> matches = snapshot.data.value;
            if (matches.isNotEmpty) {
              return _buildMatchList(matches, competitors);
            } else {
              return _buildEmptyState();
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );

  void _onSaveMatchResultPressed(
      Match match, int homeCompetitorId, int awayCompetitorId) {
    try {
      final homeScore = int.parse(_homeController.text);
      final awayScore = int.parse(_awayController.text);
      match
        ..winnerPoints = max(homeScore, awayScore)
        ..loserPoints = min(homeScore, awayScore)
        //TODO add priority
        ..winner = homeScore >= awayScore ? homeCompetitorId : awayCompetitorId;
      BlocProvider.getBloc<MatchBloc>().updateMatch(match);
      Navigator.pop(context);
    } catch (_) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)
                .translate('matches_result_dialog_error_snackbar'),
          ),
        ),
      );
    }
  }

  void _buildResultInputDialog(BuildContext context, Match match,
          Competitor home, Competitor away) =>
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
                      height: 32,
                    ),
                    RaisedButton(
                      child: Text(AppLocalizations.of(context)
                          .translate('matches_result_dialog_save')),
                      onPressed: () =>
                          _onSaveMatchResultPressed(match, home.id, away.id),
                    ),
                  ],
                ),
              ),
            );
          });

  Widget _buildMatchList(List<Match> matches, List<Competitor> competitors) =>
      ListView.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            final home = competitors
                .firstWhere((element) => element.id == match.homeCompetitor);
            final away = competitors
                .firstWhere((element) => element.id == match.awayCompetitor);
            return Padding(
              padding: EdgeInsets.all(16),
              child: Card(
                child: InkWell(
                  onTap: () =>
                      _buildResultInputDialog(context, match, home, away),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(home.name),
                            Text(
                              AppLocalizations.of(context)
                                  .translate('matches_list_horizontal_divider'),
                            ),
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

  Widget _buildEmptyState() => Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            AppLocalizations.of(context).translate('matches_list_empty_state'),
          ),
        ),
      );
}
