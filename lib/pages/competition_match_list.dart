import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/match_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/widgets/matches_list.dart';
import 'package:fencing_competition/widgets/results_table.dart';
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
      child: BlocProvider(
        blocs: [Bloc((_) => MatchBloc(competition.id))],
        child: Scaffold(
          appBar: AppBar(
            title: Text(competition.name),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _onDeletePressed(context),
              )
            ],
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
              MatchesList(),
              ResultsTable(),
            ],
          ),
        ),
      ),
    );
  }

  void _onDeletePressed(BuildContext context) async{
    //if the user decides to delete the competition in the dialog, pop this page
    if(await _showDeletionDialog(context)){
      Navigator.pop(context);
    }
  }

  Future<bool> _showDeletionDialog(BuildContext context) =>
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)
                  .translate('matches_delete_dialog_title'),
            ),
            content: Text(
              AppLocalizations.of(context)
                  .translate('matches_delete_dialog_message'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('matches_delete_dialog_action_negative'),
                  style: TextStyle(
                      color: Colors.redAccent
                  ),
                ),
                onPressed: () {
                  BlocProvider.getBloc<MatchBloc>().deleteCompetition();
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: new Text(
                  AppLocalizations.of(context)
                      .translate('matches_delete_dialog_action_positive'),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ));
}
