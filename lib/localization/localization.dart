import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:parrot_pronunciation_app/localization/localization.en.dart';
import 'package:parrot_pronunciation_app/localization/localization.pt.dart';

class LocalizationController {

  LocalizationController(this.locale);

  static const String defaultLang = 'en';
  static const availableLangs = ['en', 'pt'];

  final Locale locale;
  static BuildContext _context;

  static LocalizationController of(BuildContext context) {

    if (_context == null) {
      _context = context;
    }

    try {
      var tmp =Localizations.of<LocalizationController>(_context, LocalizationController);

      if (tmp == null) {
        tmp = new LocalizationController(new Locale(defaultLang, ''));
        _context = null;
      }

      return tmp;

    } catch (e) {
      print(e.toString());
      return new LocalizationController(new Locale(defaultLang, ''));
    }
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': enLocalization,
    'pt': ptLocalization,
  };

  String _doGetLocalizedText(String id) {
    String langCode = locale.languageCode;

    // My default language is EN
    langCode = (availableLangs.contains(langCode)) ? langCode : defaultLang;

    return _localizedValues[langCode][id];
  }

  // One function to each translated text
  String get appTitle {
    return _doGetLocalizedText('appTitle');
  }

  String get inputWord {
    return _doGetLocalizedText('inputWord');
  }

  String get inputHint {
    return _doGetLocalizedText('inputHint');
  }

  String get invalidTextInput {
    return _doGetLocalizedText('invalidTextInput');
  }
}

class MyLocalizationDelegate extends LocalizationsDelegate<LocalizationController> {
  const MyLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => LocalizationController.availableLangs.contains(locale.languageCode);

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
