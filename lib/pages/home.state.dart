import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  FlutterSound _flutterSound;
  TtsController _ttsController;
  ConfigProvider _configProvider;
  bool _isPlaying = false;
  String _speakLanguage;
  String _voice;
  String _myLanguage;
  // recording control
  bool _isRecording = false;
  String _lastRecording;

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
                onPressed: _speechText,
                btnColor: Colors.green,
                icon: Icons.volume_up,
                enabled: !_isPlaying && !_isRecording,
              ),
              _buildRecordingField(),
              IconButton(
                icon: Icon(Icons.forum),
                onPressed: null,
              ),
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
            Text(LocalizationController.of(context).recordAudio,
                style: TextStyle(color: Colors.green, fontSize: 12)
            ),
            Text(''),
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
                  onPressed: () => {},
                  icon: Icons.mic,
                  btnColor: (_isRecording) ? Colors.red : Colors.green,
                  size: (_isRecording) ? 50 : null,
                  enabled: !_isPlaying,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _recordWhilePressed() async {
    // make sure that only one loop is active
    if (_isRecording) return;

    setState(() {
      _isRecording = true;
    });

    _flutterSound = new FlutterSound();
    _lastRecording = await _flutterSound.startRecorder(_getRecordFileName());

//    _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
//      DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
//      String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
//    });

    Fluttertoast.showToast(msg: _lastRecording);
    while (_isRecording) {
      // wait a bit
      await Future.delayed(Duration(milliseconds: 200));
    }

    _lastRecording = await _flutterSound.stopRecorder();

//    if (_recorderSubscription != null) {
//      _recorderSubscription.cancel();
//      _recorderSubscription = null;
//    }

    Fluttertoast.showToast(msg: _lastRecording);

    _flutterSound = null;
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

  void _speechText() {
    if (_textControllerInputWord.text.isEmpty) {
      Fluttertoast.showToast(
        msg: LocalizationController.of(context).invalidTextInput,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
      );
      return null;
    }

    _ttsController.speak(_textControllerInputWord.text);
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
        _isPlaying = _ttsController.isPlaying;
      });
    }
  }
}
