import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// https://github.com/dlutton/flutter_tts/blob/master/example/lib/main.dart

enum TtsState { playing, stopped }
enum TtsCallbackStatus { start, completion, error }

//class TtsContext {
//  static TtsController ttsController;
//
//}

class TtsController {
  TtsController({this.statusCallback});

  final void Function(TtsCallbackStatus) statusCallback;

  FlutterTts flutterTts;
  dynamic languages;
  dynamic voices;
  String language;
  String voice;
  String lastError;
  String _newVoiceText;
  TtsState ttsState = TtsState.stopped;
  bool isInitialized = false;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;

  initTts() {
    if (!isInitialized) {
      flutterTts = FlutterTts();

      if (Platform.isAndroid) {
        flutterTts.ttsInitHandler(() {
          getLanguages();
          _getVoices();
        });
      } else if (Platform.isIOS) {
        getLanguages();
      }

      flutterTts.setStartHandler(() {
        lastError = '';
        ttsState = TtsState.playing;
        statusCallback(TtsCallbackStatus.start);
      });

      flutterTts.setCompletionHandler(() {
        lastError = '';
        ttsState = TtsState.stopped;
        statusCallback(TtsCallbackStatus.completion);
      });

      flutterTts.setErrorHandler((msg) {
        ttsState = TtsState.stopped;
        lastError = msg;
        statusCallback(TtsCallbackStatus.error);
      });

      isInitialized = true;
    }
  }

  Future<dynamic> getLanguages() async {
    languages = await flutterTts.getLanguages;
    return languages;
  }

  Future _getVoices() async {
    voices = await flutterTts.getVoices;
  }

  Future _speak() async {
    if (_newVoiceText != null) {
      if (_newVoiceText.isNotEmpty) {
        var result = await flutterTts.speak(_newVoiceText);
        if (result == 1)
          ttsState = TtsState.playing;
      }
    }
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) //setState(() => ttsState = TtsState.stopped);
      ttsState = TtsState.stopped;
  }

  void speak(String text) {
    _newVoiceText = text;
    _speak();
  }

  void stop() {
    _stop();
  }

  List<DropdownMenuItem<String>> getVoiceDropDownMenuItems() {
    var items = List<DropdownMenuItem<String>>();
    for (String type in voices) {
      items.add(DropdownMenuItem(value: type, child: Text(type)));
    }
    return items;
  }

  void changedVoiceDropDownItem(String selectedType) {
    //  setState(() {
    voice = selectedType;
    flutterTts.setVoice(voice);
    //  });
  }

/*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text('Flutter TTS'),
            ),
            body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(children: [
                  inputSection(),
                  btnSection(),
                  languages != null ? languageDropDownSection() : Text(""),
                  voices != null ? voiceDropDownSection() : Text("")
                ]))));
  }
*/

/*
  Widget btnSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _buildButtonColumn(
            Colors.green, Colors.greenAccent, Icons.play_arrow, 'PLAY', _speak),
        _buildButtonColumn(
            Colors.red, Colors.redAccent, Icons.stop, 'STOP', _stop)
      ]));
*/

/*
  Widget languageDropDownSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(),
          onChanged: changedLanguageDropDownItem,
        )
      ]));
*/

/*
  Widget voiceDropDownSection() => Container(
      padding: EdgeInsets.only(top: 50.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: voice,
          items: getVoiceDropDownMenuItems(),
          onChanged: changedVoiceDropDownItem,
        )
      ]));
*/

/*
  Column _buildButtonColumn(Color color, Color splashColor, IconData icon,
      String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }
  */
}
