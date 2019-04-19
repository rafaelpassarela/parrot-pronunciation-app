import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:parrot_pronunciation_app/screens/feedback.screen.dart';

import 'package:parrot_pronunciation_app/screens/home.screen.dart';
import 'package:parrot_pronunciation_app/screens/config.screen.dart';
import 'package:parrot_pronunciation_app/localization/localization.dart';

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
      title: 'App Title',
      // Home property does not work with route
      /* home: HomePage(
          title: 'Dummy Text'
      ), */
      initialRoute: '/',
      routes: {
        // when navigate to '/' route, build the homeScreen
        '/': (context) => HomePage(),
        // when navigate to '/config' route, build the configScreen
        '/config': (context) => ConfigScreen(),
        '/feedback': (context) => FeedBackScreen(),
      },

    );
  }
}

void main() {
  runApp(MyApp());
}