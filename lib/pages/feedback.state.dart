import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parrot_pronunciation_app/http/http.controller.dart';
import 'package:parrot_pronunciation_app/localization/localization.dart';
import 'package:parrot_pronunciation_app/widgets/circular.button.dart';

class FeedBackPage extends StatefulWidget {
  @override
  _FeedBackPageState createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage>{
  TextEditingController _nameTextEditingController = new TextEditingController();
  TextEditingController _emailTextEditingController = new TextEditingController();
  TextEditingController _messageTextEditingController = new TextEditingController();
  bool _sending = false;
  final FocusNode _nameFocus = new FocusNode();
  final FocusNode _emailFocus = new FocusNode();
  final FocusNode _messageFocus = new FocusNode();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text( LocalizationController.of(context).navbarFeedback ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            _buildInputTextField(
                LocalizationController.of(context).feedbackName, false, false,
                _nameTextEditingController, _nameFocus),
            _buildInputTextField(
                LocalizationController.of(context).feedbackEmail, false, true,
                _emailTextEditingController, _emailFocus),
            _buildInputTextField(
                LocalizationController.of(context).feedbackMessage, true, false,
                _messageTextEditingController, _messageFocus),
            _sendButton(),
          ],
        ),
      ),
    );
  }

  Widget _sendButton() {
    if (_sending) {
      return CircularProgressIndicator();
    }
    return CircularButton(
      name: 'btnFeedback',
      btnColor: Colors.green,
      icon: Icons.send,
      onPressed: _sendFeedback,
      enabled: !_sending,
    );
  }

  Widget _buildInputTextField(
      String label, bool isMemo, bool isMail,
      TextEditingController controller, FocusNode focus) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 20, right: 20, top: 20),
      child: TextFormField(
        autofocus: true,
        maxLines: (isMemo) ? null : 1,
        maxLength: (isMemo) ? 2000 : 100,
        keyboardType: (isMail) ? TextInputType.emailAddress : (isMemo) ? TextInputType.multiline : TextInputType.text,
        textInputAction: (isMemo) ? TextInputAction.newline : TextInputAction.next,
        cursorColor: Colors.green,
        controller: controller,
        enabled: !_sending,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        focusNode: focus,
        onFieldSubmitted: (term){
          if (isMail) {
            _emailFocus.unfocus();
            FocusScope.of(context).requestFocus(_messageFocus);
          } else {
            if (!isMemo) {
              _nameFocus.unfocus();
              FocusScope.of(context).requestFocus(_emailFocus);
            }
          }
        }
      ),
    );
  }

  void _sendFeedback() {

    if (!_validData()) {
      Fluttertoast.showToast(
        msg: LocalizationController.of(context).feedbackRequired,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red[300],
      );
      return;
    }

    String url = _getUrl();
    String json = '{'
        + '"name":"' + _nameTextEditingController.text + '",'
        + '"email":"' + _emailTextEditingController.text + '",'
        + '"subject":"' + LocalizationController.of(context).appTitle + ' - Feedback",'
        + '"sendCopy":false,'
        + '"locale":1,'
        + '"message":"' + _messageTextEditingController.text + '"}';

    final HttpController httpController = new HttpController();

    setState(() {
      Fluttertoast.showToast(
        msg: LocalizationController.of(context).feedbackSending,
        toastLength: Toast.LENGTH_LONG,
      );
      _sending = true;
    });

    httpController.createPost(
      url,
      body: json,
      thenCallback: _sendResponse,
      errorCallback: _errorCallback
    );
  }

  void _sendResponse(http.Response value) {
    setState(() {
      _sending = false;
      if (value.statusCode < 200 || value.statusCode > 400) {
        Fluttertoast.showToast(
          msg: value.statusCode.toString() + ' - ' + value.reasonPhrase,
          backgroundColor: Colors.red[300],
        );
      } else {
        Fluttertoast.showToast(
            msg: LocalizationController.of(context).feedbackThanks,
        );
        Navigator.pop(context);
      }
    });
  }

  void _errorCallback() {
    setState(() {
      _sending = false;
    });
  }

  bool _validData() {
    return _nameTextEditingController.text.isNotEmpty
        && _emailTextEditingController.text.isNotEmpty
        && _messageTextEditingController.text.isNotEmpty;
  }

  String _getUrl() {
    return "http://mrrafael.ca/api/v1/sendcontact.php?'"
         + "id=05372adefd0093adf1fbcab0c2c6597de09f1376be";
  }
}

