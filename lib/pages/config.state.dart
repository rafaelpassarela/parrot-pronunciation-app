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
  ConfigProvider _configProvider;
  //String _selectedLanguage;
  //String _mySelectedLanguage;
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

  @override
  void initState() {
    super.initState();

    _configProvider = new ConfigProvider();
    _configProvider.open().then(
        (dynamic) {
          _loadValues();
        }
    );

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
  }

  @override
  void deactivate() {
    if (_configProvider != null) {
      _configProvider.close();
    }
    super.deactivate();
  }

  void _loadValues() {
    // load speak language
    _configProvider.getConfig(CONFIG_SPK_LANG).then(
        (Config config) {
          String value;
          if (config != null) {
            value = config.value;
            _selectedLanguage.id = config.id;
          }

          if (_selectedLanguage.value != value) {
            setState(() {
              _selectedLanguage.value = value;
            });
          }
        }
    );

    // load my language
    _configProvider.getConfig(CONFIG_MY_LANG).then(
        (Config config) {
          String value;
          if (config != null) {
            value = config.value;
            _mySelectedLanguage.id = config.id;
          }

          if (_mySelectedLanguage.value != value) {
            setState(() {
              _mySelectedLanguage.value = value;
            });
          }
        }
    );
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
            getRow(LocalizationController.of(context).configSpeak, _languageDropDownSection() ),
            getRow(LocalizationController.of(context).configYourLang, _myLanguageDropDownSection() ),
          ],
        ),
      ),
    );
  }

  Widget _languageDropDownSection() {
    return DropdownButton(
      isExpanded: true,
      value: _selectedLanguage.value,
      items:
          (_availableLanguages != null) ? getLanguageDropDownMenuItems() : null,
      onChanged: changedLanguageDropDownItem,
    );
  }

  Widget _myLanguageDropDownSection() {
    return DropdownButton(
      isExpanded: true,
      value: _mySelectedLanguage.value,
      items:
      (_availableLanguages != null) ? getLanguageDropDownMenuItems() : null,
      onChanged: changedMyLanguageDropDownItem,
    );
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

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in _availableLanguages) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }


}
