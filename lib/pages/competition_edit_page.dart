import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/competition_creation_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:fencing_competition/widgets/competitor_creation.dart';
import 'package:flutter/material.dart';

class CompetitionEditPage extends StatefulWidget {
  static const NAVIGATION_KEY = "/competition/edit";

  @override
  State createState() => _CompetitionEditPageState();
}

class _CompetitionEditPageState extends State<CompetitionEditPage> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Competition currentCompetition =
        ModalRoute.of(context).settings.arguments ??
            Competition(
                null,
                AppLocalizations.of(context)
                    .translate('competition_editor_new_title'));

    _nameController.text = currentCompetition.name;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentCompetition.name),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context)
                    .translate('competition_editor_name_input_description'),
              ),
              controller: _nameController,
            ),
            SizedBox(
              height: 16,
            ),
            Expanded(
              child: CompetitorCreationWidget(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _onSaveButtonPressed(currentCompetition),
        label: Text(
          AppLocalizations.of(context).translate('competition_editor_save'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSaveButtonPressed(Competition competition){
    competition.name = _nameController.text;
    BlocProvider.getBloc<CompetitionCreationBloc>()
        .addCompetition(competition)
        .then((value) {
      Navigator.pop(context);
    });
  }
}
