import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/match_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
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
    return BlocProvider(
      blocs: [Bloc((_) => MatchBloc(competition.id))],
      child: DefaultTabController(
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
            children: [MatchesList(), ResultsList()],
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
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Match>>(
        stream: BlocProvider.getBloc<MatchBloc>().matches,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<Match> matches = snapshot.data;

            return ListView.builder(
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [

                          ],
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
}


class ResultsList extends StatefulWidget {
  @override
  State createState() => _MatchesListState();
}

class _ResultsListState extends State<ResultsList> {
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Match>>(
    stream: BlocProvider.getBloc<MatchBloc>().matches,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final List<Match> matches = snapshot.data;

        return Container();
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}
