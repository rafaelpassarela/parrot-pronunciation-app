import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:parrot_pronunciation_app/home/home.state.dart';
import 'package:parrot_pronunciation_app/localization/localization.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      localizationsDelegates: [
        const MyLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('pt', ''),
      ],
      // title: LocalizationController.of(context).title,
      onGenerateTitle: (BuildContext context) => LocalizationController.of(context).appTitle,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(
          title: 'Dummy Text'
      )

    );
  }
}