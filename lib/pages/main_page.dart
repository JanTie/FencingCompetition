import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/competition_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/pages/competition_edit_page.dart';
import 'package:fencing_competition/pages/competition_match_list.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  static const NAVIGATION_KEY = "/";

  @override
  State createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  CompetitionBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = CompetitionBloc();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('app_title')),
        ),
        body: StreamBuilder<List<Competition>>(
          stream: bloc.competitions,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final competitions = snapshot.data;
              if (competitions.isEmpty) {
                return _buildEmptyState();
              } else {
                return _buildList(competitions);
              }
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _onAddFabPressed,
        ),
      );

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  void _onItemTap(Competition competition) async {
    await Navigator.pushNamed(context, CompetitionMatchList.NAVIGATION_KEY,
        arguments: competition);
    //reload competitions
    bloc.getCompetitions();
  }

  void _onAddFabPressed() async{
    await Navigator.pushNamed(
        context, CompetitionEditPage.NAVIGATION_KEY);
    bloc.getCompetitions();
  }

  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(AppLocalizations.of(context)
          .translate('competitions_empty_state')),
    ),
  );

  Widget _buildList(List<Competition> competitions) => ListView.builder(
      itemCount: competitions.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          child: InkWell(
            onTap: () => _onItemTap(competitions[index]),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(competitions[index].name),
            ),
          ),
        ),
      ));
}
