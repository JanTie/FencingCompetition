import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/match_bloc.dart';
import 'package:fencing_competition/model/result.dart';
import 'package:flutter/material.dart';

class ResultsTable extends StatefulWidget {
  @override
  State createState() => _ResultsTableState();
}

class _ResultsTableState extends State<ResultsTable> {
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
