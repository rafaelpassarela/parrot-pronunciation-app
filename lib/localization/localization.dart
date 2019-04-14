import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class LocalizationController {

  LocalizationController(this.locale);

  final Locale locale;
  static BuildContext _context;

  static LocalizationController of(BuildContext context) {

    if (_context == null) {
      _context = context;
    }

    try {
      var tmp =Localizations.of<LocalizationController>(_context, LocalizationController);

      if (tmp == null) {
        tmp = new LocalizationController(new Locale('en', 'CA'));
        _context = null;
      }

      return tmp;

    } catch (e) {
      print(e.toString());
      return new LocalizationController(new Locale('en', 'CA'));
    }
  }

  static Map<String, Map<String, String>> _localizedValues = {
    // EN Localizations
    'en': {
      'appTitle': 'Parrot - Practice the Pronunciation',
      'test': 'Your total clicks is:'
    },
    // PT Localizations
    'pt': {
      'appTitle': 'Papagaio - Pratique a Pronúncia',
      'test': 'Seu total de clicadas é:'
    },
  };

  String get appTitle {
    return _localizedValues[locale.languageCode]['appTitle'];
  }

  String get test {
    return _localizedValues[locale.languageCode]['test'];
  }
}

class MyLocalizationDelegate
    extends LocalizationsDelegate<LocalizationController> {
  const MyLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pt'].contains(locale.languageCode);

  @override
  Future<LocalizationController> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of LocalizationController.
    return SynchronousFuture<LocalizationController>(
        LocalizationController(locale));
  }

  @override
  bool shouldReload(MyLocalizationDelegate old) => false;
}
