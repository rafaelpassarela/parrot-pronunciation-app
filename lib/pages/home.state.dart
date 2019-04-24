import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:parrot_pronunciation_app/database/config.controller.dart';
import 'package:parrot_pronunciation_app/database/db.const.dart';
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

  @override
  void initState() {
    super.initState();
    _ttsController = new TtsController(statusCallback: _statusCallback);
    _ttsController.initTts();

    _initConfigDataBase();
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
                btnColor: Colors.green,
                icon: Icons.volume_up,
                enabled: !_isSpeaking && !_isRecording && !_isPlaying,
              ),
              _buildRecordingField(),
              _buildPlayField(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        fixedColor: Colors.green,
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
            color: Colors.green,
            width: 2,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
                LocalizationController.of(context).recordAudio,
                style: TextStyle(color: Colors.green, fontSize: 12)
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
                  btnColor: (_isRecording) ? Colors.red : Colors.green,
                  size: (_isRecording) ? 50 : null,
                  enabled: !_isSpeaking,
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
            color: Colors.green,
            width: 2,
          ),
        ),
        child: Column(
          children: <Widget>[
            Text(
                LocalizationController.of(context).playAndCompare,
                style: TextStyle(color: Colors.green, fontSize: 12)
            ),
            Container(
              child: CircularButton(
                name: 'btnPlay',
                onPressed: _playForCompare,
                icon: Icons.forum,
                btnColor: Colors.green,
                enabled: !_isSpeaking && !_isRecording,
              ),
            ),
            Text( '$_currentStatus'),
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

//    _flutterSound = new FlutterSound();
    _lastRecordFile = await _flutterSound.startRecorder(_getRecordFileName());

    _recorderSubscription = _flutterSound.onRecorderStateChanged.listen((e) {
      DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
      setState(() {
        _recordingTime = DateFormat('mm:ss:SS', 'en_US').format(date);
      });
    });

    while (_isRecording) {
      // wait a bit
      await Future.delayed(Duration(milliseconds: 200));
    }

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
    _speechText();

    setState(() {
      _currentStatus = LocalizationController.of(context).playYou;
    });

    await _flutterSound.startPlayer( _lastRecordFile );

    _playerSubscription = _flutterSound.onPlayerStateChanged.listen((e) {
      if (e != null) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        setState(() {
//          _playingTime = DateFormat('mm:ss:SS', 'en_US').format(date);
        });
      }
    });

    setState(() {
      _isPlaying =  false;
      _currentStatus = '';
    });
  }

  String _getRecordFileName() {
    return null;
//    return 'Parrot_Recording' + ((Platform.isAndroid) ? '.mp4' : '.m4a');
  }

  Widget _buildInputTextField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20, top: 20),
      child: TextField(
        autofocus: true,
        // maxLines = NULL: adds new lines when the current line reaches the line character limit
        maxLines: null,
        maxLength: 500,
        cursorColor: Colors.green,
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
      _configProvider.close();
    }

    await Navigator.pushNamed(context, '/config');

    // if no configurations has found, open it again
    _initConfigDataBase();
  }

  void _loadConfig() {
    _configProvider.getAllConfig().then((List<Config> configList) {
      if (configList != null) {
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
        _openConfigAndWait();
      }
    });
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
