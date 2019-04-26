import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/android_encoder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:parrot_pronunciation_app/database/config.controller.dart';
import 'package:parrot_pronunciation_app/database/db.const.dart';
import 'package:parrot_pronunciation_app/widgets/custom.color.dart';
import 'package:parrot_pronunciation_app/widgets/tts.controller.dart';
import 'package:parrot_pronunciation_app/widgets/circular.button.dart';
import 'package:parrot_pronunciation_app/localization/localization.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _textControllerInputWord = TextEditingController();
  FlutterSound _flutterSound = new FlutterSound();
  TtsController _ttsController;
  ConfigProvider _configProvider;
  bool _isSpeaking = false;
  bool _isPlaying = false;
  bool _isRecording = false;
  String _speakLanguage;
  String _voice;
  String _myLanguage;
  // recording control
  String _lastRecordFile;
  String _recordingTime = '';
  StreamSubscription<RecordStatus> _recorderSubscription;
  StreamSubscription<PlayStatus> _playerSubscription;
  String _currentStatus = '';
  String _version = '';

  @override
  void initState() {
    super.initState();

    _initConfigDataBase();

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      setState(() {
        _version = packageInfo.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/icon.png', fit: BoxFit.cover, height: 32),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(LocalizationController.of(context).appTitle),
              ),
            )
          ],
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // add additional colors to define a multi-point gradient
            colors: [Colors.white, Color(0x4089ED91)],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _buildInputTextField(),
              CircularButton(
                name: 'btnSpeechText',
                onPressed: _speechText,
                btnColor: mainAppColor,
                icon: Icons.volume_up,
                enabled: !_isSpeaking && !_isRecording && !_isPlaying,
              ),
              _buildRecordingField(),
              _buildPlayField(),
              Text('', style: TextStyle(fontSize: 18)),
              Text(_version, style: TextStyle(color: mainAppColor, fontSize: 8))

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        fixedColor: mainAppColor,
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              title: Text(LocalizationController.of(context).navbarConfig)),
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text(LocalizationController.of(context).navbarHome)),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback),
              title: Text(LocalizationController.of(context).navbarFeedback)),
        ],
      ),
    );
  }

  Widget _buildRecordingField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20, top: 20),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: mainAppColor,
            width: 2,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
                LocalizationController.of(context).recordAudio,
                style: TextStyle(color: mainAppColor, fontSize: 12)
            ),
//            Text( (_isRecording) ? '$_recordingTime' : '' ),
            Text(
              '$_recordingTime',
              style: TextStyle(
                  color: (_isRecording) ? Colors.red : null
              ),
            ),
            Container(
              width: (_isRecording) ? 80 : null,
              height: (_isRecording) ? 80 : null,
              child: Listener(
                onPointerDown: (details) {
                  setState(() {
                    _recordWhilePressed();
                  });
                },
                onPointerUp: (details) {
                  setState(() {
                    _isRecording = false;
                  });
                },
                onPointerCancel: (details) {
                  setState(() {
                    _isRecording = false;
                  });
                },
                child: CircularButton(
                  name: 'btnRecording',
                  onPressed: () => {},
                  icon: Icons.mic,
                  btnColor: (_isRecording) ? Colors.red : mainAppColor,
                  size: (_isRecording) ? 50 : null,
                  enabled: !_isSpeaking && !_isPlaying,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20, top: 20),
      child: Container(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20, top: 20),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: mainAppColor,
            width: 2,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
                LocalizationController.of(context).playAndCompare,
                style: TextStyle(color: mainAppColor, fontSize: 12)
            ),
            Text( '$_currentStatus'),
            Container(
              child: CircularButton(
                name: 'btnPlay',
                onPressed: _playForCompare,
                icon: Icons.forum,
                btnColor: mainAppColor,
                enabled: !_isSpeaking && !_isRecording && !_isPlaying,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _speechText() {
    if (_textControllerInputWord.text.trim().isEmpty) {
      Fluttertoast.showToast(
        msg: LocalizationController.of(context).invalidTextInput,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
      );
      return null;
    }

    _ttsController.speak(_textControllerInputWord.text);
  }

  void _recordWhilePressed() async {
    // make sure that only one loop is active
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
    });

    int recTime = 0;
    String fileName = await _getRecordFileName();
    _lastRecordFile = await _flutterSound.startRecorder(
      fileName,
      sampleRate: 48000,
      bitRate: 16,
      androidEncoder: AndroidEncoder.HE_AAC,
    );

    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {
      recTime = e.currentPosition.toInt();
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(recTime);

//      if (e.currentPosition.toInt() > 2500)
//        print('PAUSE para o PRINT');

      setState(() {
        _recordingTime = DateFormat('mm:ss:SS', 'en_US').format(date);
      });
    });

    while (_isRecording) {
      // wait a bit
      await Future.delayed(Duration(milliseconds: 200));
    }

    if (recTime < 500)
      await Future.delayed(Duration(milliseconds: 500 - recTime));

    await _flutterSound.stopRecorder();

    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }

//    _flutterSound = null;
    // wait a bit to prevent a new file over the last one
    await Future.delayed(Duration(milliseconds: 1000));
  }

  void _playForCompare() async {

    if (_textControllerInputWord.text.trim().isEmpty || _recordingTime == '') {
      Fluttertoast.showToast(
        msg: LocalizationController.of(context).inputWord
            + ' ' + LocalizationController.of(context).andSeparator
            + ' ' + LocalizationController.of(context).recordAudio,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
      );
      return;
    }

    setState(() {
      _isPlaying = true;
      _currentStatus = LocalizationController.of(context).playInput;
    });
    // input text (by TTS)
    try {
      _isSpeaking = true;
      _ttsController.speak(_textControllerInputWord.text);

      while (_isSpeaking) {
        await Future.delayed(Duration(milliseconds: 100));
      }
    } catch (e) {
      _isSpeaking = false;
    }

    setState(() {
      _currentStatus = LocalizationController.of(context).playYou;
    });

    await _flutterSound.startPlayer( _lastRecordFile );

    _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) {
      if (e != null) {
        if (e.currentPosition >= e.duration) {
          setState(() {
            _isPlaying = false;
            _currentStatus = '';
          });
        }
      }
    });
  }

  Future<String> _getRecordFileName() async {
    Directory tempDir = await getTemporaryDirectory();
    return tempDir.path + '/parrot_audio' + ((Platform.isAndroid) ? '.mp4' : '.m4a');
  }

  Widget _buildInputTextField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20, top: 20),
      child: TextField(
        autofocus: true,
        // maxLines = NULL: adds new lines when the current line reaches the line character limit
        maxLines: null,
        maxLength: 500,
        cursorColor: mainAppColor,
        controller: _textControllerInputWord,
        decoration: InputDecoration(
          labelText: LocalizationController.of(context).inputWord,
          helperText: LocalizationController.of(context).inputHint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (_isSpeaking || _isRecording || _isPlaying)
      return;

    switch (index) {
      case 0:
      // navigate and wait to return back
        _openConfigAndWait();
        break;
      case 1:
        break;
      case 2:
        Navigator.pushNamed(context, '/feedback');
        break;
    }
  }

  void _openConfigAndWait() async {
    // close the db connection
    if (_configProvider != null) {
      _configProvider.close(true);
    }

    await Navigator.pushNamed(context, '/config');

    // if no configurations has found, open it again
    _initConfigDataBase();
  }

  void _loadConfig() {
    _configProvider.getAllConfig().then((List<Config> configList) {

      if (configList != null) {

        // tts must be recreated to set callback again
        _initTTSController();

        for (Config item in configList) {
          switch (item.code) {
            case CONFIG_VOICE:
              _voice = item.value;
              _ttsController.setVoice(_voice);
              break;
            case CONFIG_MY_LANG:
              _myLanguage = item.value;
              break;
            case CONFIG_SPK_LANG:
              _speakLanguage = item.value;
              _ttsController.setLanguage(_speakLanguage);
              break;
          }
        }
      } else {
        // save default values and load again
        _configProvider.insertOrUpdate(new Config(code: CONFIG_SPK_LANG, value: DEF_SPK_LANG, description: DESC_SPK_LANG));
        _configProvider.insertOrUpdate(new Config(code: CONFIG_MY_LANG, value: DEF_MY_LANG, description: DESC_MY_LANG));
        _configProvider.insertOrUpdate(new Config(code: CONFIG_VOICE, value: DEF_VOICE, description: DESC_VOICE));

        // if no config, probably is the first time, request recording permissions
        try {
          _flutterSound.startRecorder(null);
        } finally {
          _flutterSound.stopRecorder();
        }
        _loadConfig();

//      _openConfigAndWait();
      }
    });
  }

  void _initTTSController() {
    if (_ttsController != null) {
      _ttsController = null;
    }

    _ttsController = new TtsController(statusCallback: _statusCallback);
    _ttsController.initTts();
  }

  void _initConfigDataBase() {
    _configProvider = new ConfigProvider();
    _configProvider.open().then((dynamic) {
      _loadConfig();
    });
  }

  void _statusCallback(TtsCallbackStatus status) {
    if (status == TtsCallbackStatus.error) {
      Fluttertoast.showToast(
        msg: _ttsController.lastError,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
      );
    } else {
      setState(() {
        _isSpeaking = _ttsController.isPlaying;
      });
    }
  }
}
