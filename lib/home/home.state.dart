import 'package:flutter/material.dart';
import 'package:parrot_pronunciation_app/widgets/tts.controller.dart';
import 'package:parrot_pronunciation_app/widgets/circular.button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parrot_pronunciation_app/localization/localization.dart';

class HomePage extends StatefulWidget {

  HomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  TextEditingController textControllerInputWord = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(LocalizationController.of(context).appTitle),
            )
          ],
        )
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // add additional colors to define a multi-point gradient
            colors: [
              Colors.white,
              Color(0x4089ED91)],
          ),
        ),
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildInputTextField(),

              CircularButton(
                onPressed: _speechText,
                icon: Icons.volume_up,
              ),
              IconButton(
                icon: Icon(Icons.mic),
                onPressed: null,
              ),
              IconButton(
                icon: Icon(Icons.forum),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildInputTextField() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        autofocus: true,
        // maxLines = NULL: adds new lines when the current line reaches the line character limit
        maxLines: null,
        cursorColor: Colors.green,
        controller: textControllerInputWord,
        decoration: InputDecoration(
          labelText: LocalizationController.of(context).inputWord,
          helperText: LocalizationController.of(context).inputHint,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _speechText() {
    if (textControllerInputWord.text.isEmpty) {
      Fluttertoast.showToast(
        msg: LocalizationController.of(context).invalidTextInput,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
      );
      return null;
    }
  }

}
