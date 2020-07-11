import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/competition_bloc.dart';
import 'package:fencing_competition/db_provider.dart';
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
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.getBloc<CompetitionBloc>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('app_title')),
      ),
      body: StreamBuilder<List<Competition>>(
        stream:
        bloc.competitions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final competitions = snapshot.data;
            if (competitions.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(AppLocalizations.of(context)
                      .translate('competitions_empty_state')),
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: competitions.length,
                  itemBuilder: (context, index) =>
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, CompetitionMatchList.NAVIGATION_KEY, arguments: competitions[index]);
                            },
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(competitions[index].name),
                            ),
                          ),
                        ),
                      ));
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
          onPressed: () {
            Navigator.pushNamed(context, CompetitionEditPage.NAVIGATION_KEY).then((value) => bloc.getCompetitions());
          }),
    );
  }
}
