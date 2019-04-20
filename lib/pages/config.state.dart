import 'package:flutter/material.dart';
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
  String _selectedLanguage;
  String _mySelectedLanguage;

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
      value: _selectedLanguage,
      items:
          (_availableLanguages != null) ? getLanguageDropDownMenuItems() : null,
      onChanged: changedLanguageDropDownItem,
    );
  }

  Widget _myLanguageDropDownSection() {
    return DropdownButton(
      isExpanded: true,
      value: _mySelectedLanguage,
      items:
      (_availableLanguages != null) ? getLanguageDropDownMenuItems() : null,
      onChanged: changedMyLanguageDropDownItem,
    );
  }

  void changedLanguageDropDownItem(String selectedType) {
    setState(() {
      _selectedLanguage = selectedType;
    });
  }

  void changedMyLanguageDropDownItem(String selectedType) {
    setState(() {
      _mySelectedLanguage = selectedType;
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
