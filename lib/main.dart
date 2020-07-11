import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:fencing_competition/app_localizations.dart';
import 'package:fencing_competition/bloc/competition_bloc.dart';
import 'package:fencing_competition/pages/competition_edit_page.dart';
import 'package:fencing_competition/pages/competition_match_list.dart';
import 'package:fencing_competition/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [Bloc((_) => CompetitionBloc())],
      child: MaterialApp(
        title: 'Fencing Tournament Manager',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          MainPage.NAVIGATION_KEY: (_) => MainPage(),
          CompetitionEditPage.NAVIGATION_KEY: (_) => CompetitionEditPage(),
          CompetitionMatchList.NAVIGATION_KEY: (_) => CompetitionMatchList(),
        },
        initialRoute: MainPage.NAVIGATION_KEY,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          //const Locale('de', ''),
          // ... other locales the app supports
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
      ),
    );
  }
}
