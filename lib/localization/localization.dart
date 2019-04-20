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
  String get appTitle => _doGetLocalizedText('appTitle');
  String get configTitle => _doGetLocalizedText('configTitle');
  String get inputWord => _doGetLocalizedText('inputWord');
  String get inputHint => _doGetLocalizedText('inputHint');
  String get invalidTextInput => _doGetLocalizedText('invalidTextInput');
  // navbar Items
  String get navbarHome => _doGetLocalizedText('navbar.home');
  String get navbarConfig => _doGetLocalizedText('navbar.config');
  String get navbarFeedback => _doGetLocalizedText('navbar.feedback');
  // feedback scrren
  String get feedbackName => _doGetLocalizedText('feed.name');
  String get feedbackEmail => _doGetLocalizedText('feed.mail');
  String get feedbackMessage => _doGetLocalizedText('feed.message');
  String get feedbackRequired => _doGetLocalizedText('feed.required');
  String get feedbackSending => _doGetLocalizedText('feed.sending');
  String get feedbackThanks => _doGetLocalizedText('feed.tks');
  // config
  String get configSpeak => _doGetLocalizedText('config.speak');
  String get configYourLang => _doGetLocalizedText('config.yourlang');
  String get configVoice => _doGetLocalizedText('config.voice');
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
