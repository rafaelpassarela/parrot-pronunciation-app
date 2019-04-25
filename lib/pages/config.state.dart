import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parrot_pronunciation_app/database/config.controller.dart';
import 'package:parrot_pronunciation_app/database/db.const.dart';
import 'package:parrot_pronunciation_app/widgets/tts.controller.dart';
import 'package:parrot_pronunciation_app/localization/localization.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final TtsController _ttsController =
      new TtsController(statusCallback: (TtsCallbackStatus status) => {});

  List<String> _availableLanguages;
  List<String> _availableVoices;
  ConfigProvider _configProvider;
  Config _selectedLanguage = new Config(
    id: null,
    code: CONFIG_SPK_LANG,
    description: 'Speak Localization',
    value: null,
  );
  Config _mySelectedLanguage = new Config(
    id: null,
    code: CONFIG_MY_LANG,
    description: 'My Native Localization',
    value: null,
  );
  Config _selectedVoice = new Config(
    id: null,
    code: CONFIG_VOICE,
    description: 'Selected Voice',
    value: null,
  );

  @override
  void initState() {
    super.initState();

    _ttsController.initTts();
    _ttsController.getLanguages().then((dynamic value) {
      _availableLanguages = new List<String>();

      for (String item in value) {
        _availableLanguages.add(item);
      }
      setState(() {
        _availableLanguages.sort();
      });
    });

    if (Platform.isAndroid) {
      _ttsController.getVoices().then((dynamic value) {
        _availableVoices = new List<String>();

        for (String item in value) {
          _availableVoices.add(item);
        }
        setState(() {
          _availableVoices.sort();
        });
      });
    }

    _configProvider = new ConfigProvider();
    _configProvider.open().then((dynamic) {
      _loadAllValues();
    });
  }

  @override
  void deactivate() {
    if (_configProvider != null) {
      _configProvider.close(true);
    }
    super.deactivate();
  }

  void _loadAllValues() {
    _configProvider.getAllConfig().then((List<Config> configList) {
      // set default values, and do not refresh the state
      String spkLang;
      String myLang;
      String voice;

      if (configList != null) {
        for (Config item in configList) {
          switch (item.code) {
            case CONFIG_SPK_LANG:
              _selectedLanguage.id = item.id;
              spkLang = item.value;
              break;

            case CONFIG_MY_LANG:
              _mySelectedLanguage.id = item.id;
              myLang = item.value;
              break;

            case CONFIG_VOICE:
              _selectedVoice.id = item.id;
              voice = item.value;
              break;
          }
        }
      }

      if (spkLang == null && _availableLanguages.indexOf(DEF_SPK_LANG) > -1)
        spkLang = DEF_SPK_LANG;
      if (myLang == null && _availableLanguages.indexOf(DEF_MY_LANG) > -1)
        myLang = DEF_MY_LANG;
      if (voice == null && _availableVoices.indexOf(DEF_VOICE) > -1)
        voice = DEF_VOICE;

      setState(() {
        _selectedLanguage.value = spkLang;
        _mySelectedLanguage.value = myLang;
        _selectedVoice.value = voice;
      });
      _configProvider.insertOrUpdate(_selectedLanguage);
      _configProvider.insertOrUpdate(_mySelectedLanguage);
      _configProvider.insertOrUpdate(_selectedVoice);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizationController.of(context).configTitle),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            getRow(LocalizationController.of(context).configSpeak,
                _languageDropDownSection()),
            getRow(LocalizationController.of(context).configYourLang,
                _myLanguageDropDownSection()),
            getRow(LocalizationController.of(context).configVoice,
                _voiceDropDownSection()),
          ],
        ),
      ),
    );
  }

  Widget _languageDropDownSection() {
    return DropdownButton(
      isExpanded: true,
      value: _selectedLanguage.value,
      items: (_availableLanguages != null)
          ? _getLanguageDropDownMenuItems()
          : null,
      onChanged: changedLanguageDropDownItem,
    );
  }

  Widget _myLanguageDropDownSection() {
    return DropdownButton(
      isExpanded: true,
      value: _mySelectedLanguage.value,
      items: (_availableLanguages != null)
          ? _getLanguageDropDownMenuItems()
          : null,
      onChanged: changedMyLanguageDropDownItem,
    );
  }

  Widget _voiceDropDownSection() {
    return DropdownButton(
      isExpanded: true,
      value: _selectedVoice.value,
      items:
          (_availableVoices != null) ? _getVoiceDropDownMenuItems() : null,
      onChanged: changedVoiceDropDownItem,
    );
  }

  List<DropdownMenuItem<String>> _getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in _availableLanguages) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> _getVoiceDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in _availableVoices) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      _selectedLanguage.value = selectedType;
      _configProvider.insertOrUpdate(_selectedLanguage);
    });
  }

  void changedMyLanguageDropDownItem(String selectedType) {
    setState(() {
      _mySelectedLanguage.value = selectedType;
      _configProvider.insertOrUpdate(_mySelectedLanguage);
    });
  }

  void changedVoiceDropDownItem(String selectedType) {
    setState(() {
      _selectedVoice.value = selectedType;
      _configProvider.insertOrUpdate(_selectedVoice);
    });
  }

  Widget getRow(String caption, Widget input) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(caption),
            flex: 2,
          ),
          Expanded(
            child: input,
            flex: 3,
          )
        ],
      ),
    );
  }
}
