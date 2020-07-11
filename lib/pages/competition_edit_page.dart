import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/competition_bloc.dart';
import 'package:fencing_competition/model/competition.dart';
import 'package:fencing_competition/model/competitor.dart';
import 'package:flutter/material.dart';

class CompetitionEditPage extends StatefulWidget {
  static const NAVIGATION_KEY = "/competition/edit";

  @override
  State createState() => _CompetitionEditPageState();
}

class _CompetitionEditPageState extends State<CompetitionEditPage> {
  final _nameController = TextEditingController();
  final _competitorNameController = TextEditingController();
  List<Competitor> competitors = [];

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
            TextField(
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      _nameController.text = this._nameController.text;
                      competitors.add(Competitor(
                          null, _competitorNameController.text, null));
                    });
                    _competitorNameController.text = "";
                  },
                ),
                border: InputBorder.none,
                labelText: AppLocalizations.of(context).translate(
                    'competition_editor_competitor_name_input_description'),
              ),
              controller: _competitorNameController,
            ),
            Expanded(
              child: competitors.length == 0
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
                            competitors.removeAt(index);
                          },
                        );
                      }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          currentCompetition.name = _nameController.text;
          BlocProvider.getBloc<CompetitionBloc>()
              .addCompetition(currentCompetition, this.competitors)
              .then((value) {
            Navigator.pop(context);
          });
        },
        label: Text(
          AppLocalizations.of(context).translate('competition_editor_save'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _competitorNameController.dispose();
    super.dispose();
  }
}
