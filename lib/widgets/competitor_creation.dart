import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/competition_creation_bloc.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:flutter/material.dart';

class CompetitorCreationWidget extends StatefulWidget {
  @override
  State createState() => _CompetitorCreationWidgetState();
}

class _CompetitorCreationWidgetState extends State<CompetitorCreationWidget> {
  final _competitorNameController = TextEditingController();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          _buildNameInputField(),
          _buildCompetitorList(),
        ],
      );

  @override
  void dispose() {
    _competitorNameController.dispose();
    super.dispose();
  }

  void _onAddCompetitorPressed(String input) {
    if (input.isNotEmpty) {
      BlocProvider.getBloc<CompetitionCreationBloc>().addCompetitor(
        Competitor(name: input),
      );
      _competitorNameController.text = "";
    }
  }

  Widget _buildNameInputField() => TextField(
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: () =>
                _onAddCompetitorPressed(_competitorNameController.text),
          ),
          border: InputBorder.none,
          labelText: AppLocalizations.of(context).translate(
              'competition_editor_competitor_name_input_description'),
        ),
        controller: _competitorNameController,
        onSubmitted: (name) => _onAddCompetitorPressed(name),
      );

  Widget _buildCompetitorList() => Expanded(
        child: StreamBuilder<List<Competitor>>(
          stream: BlocProvider.getBloc<CompetitionCreationBloc>().competitors,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<Competitor> competitors = snapshot.data;
              return _buildList(competitors);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

  Widget _buildList(List<Competitor> competitors) => competitors.length == 0
      ? Text(AppLocalizations.of(context)
          .translate('competition_editor_competitor_empty_state'))
      : ListView.builder(
          shrinkWrap: true,
          itemCount: competitors.length,
          itemBuilder: (context, index) {
            return Dismissible(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(competitors[index].name),
                  ),
                ),
              ),
              key: Key(competitors[index].hashCode.toString()),
              onDismissed: (direction) {
                BlocProvider.getBloc<CompetitionCreationBloc>()
                    .removeCompetitor(competitors[index]);
              },
            );
          });
}
