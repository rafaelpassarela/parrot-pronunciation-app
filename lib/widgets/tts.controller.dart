import 'dart:async';
import 'dart:io';
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
          getVoices();
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

  Future<dynamic> getVoices() async {
    voices = await flutterTts.getVoices;
    return voices;
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

  void setVoice(String newVoice) {
    voice = newVoice;
    flutterTts.setVoice(voice);
  }

  void setLanguage(String newLanguage) {
    language = newLanguage;
    flutterTts.setLanguage(language);
  }

}
