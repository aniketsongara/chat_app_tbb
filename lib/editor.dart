import 'audio.dart';
import 'const.dart';
import 'images.dart';
import 'video.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

class EditorPage extends StatefulWidget {
  final String serverFile;

  EditorPage({this.serverFile});

  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  /// Allows to control the editor and the document.
  ZefyrController _controller;
  bool _editing = false;

  /// Zefyr editor like any other input field requires a focus node.
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.serverFile == null) {
      _loadDocument().then((document) {
        setState(() {
          _controller = ZefyrController(document);
        });
      });
    } else {
      downloadFile(widget.serverFile).then((document) {
        setState(() {
          _controller = ZefyrController(document);
        });
      });
    }
  }

  void _startEditing() {
    setState(() {
      _editing = true;
    });
  }

  void _stopEditing() {
    setState(() {
      _editing = false;
    });
    _saveDocument(context);
  }

  Future<NotusDocument> downloadFile(String url) async {
    print('Coming in downloadFile function !');

    final http.Response downloadData = await http.get(url);
    final file = File(Directory.systemTemp.path + "/tmp.json");
    if (file.existsSync()) {
      await file.delete();
    }
    await file.create();
    file.writeAsString(downloadData.body).then((_) {
      // Navigator.pop(context,file);
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });

    print('Json body : ${downloadData.body}');

    if (file != null) {
      final contents = await file.readAsString();
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    return NotusDocument.fromJson(jsonDecode(downloadData.body));
  }

  @override
  Widget build(BuildContext context) {
    final done = _editing
        ? IconButton(onPressed: _stopEditing, icon: Icon(Icons.save))
        : IconButton(onPressed: _startEditing, icon: Icon(Icons.edit));
    final Widget body = (_controller == null)
        ? Center(child: CircularProgressIndicator())
        : ZefyrScaffold(
            child: ZefyrEditor(
              padding: EdgeInsets.all(16),
              controller: _controller,
              focusNode: _focusNode,
              mode: widget.serverFile != null
                  ? ZefyrMode.select
                  : _editing ? ZefyrMode.edit : ZefyrMode.select,
              audioDelegate: CustomAudioDelegate(),
              videoDelegate: CustomVideoDelegate(),
              imageDelegate: CustomImageDelegate(),
            ),
          );
    return Scaffold(
      appBar: AppBar(
        title: Text("Editor page"),
        // <<< begin change
        actions: <Widget>[
          Visibility(
            child: Builder(
              builder: (context) => done,
            ),
            visible: widget.serverFile != null ? false : true,
          ),
          Visibility(
            child: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _sendDocument(context),
              ),
            ),
            visible: widget.serverFile != null ? false : true,
          )
        ],
        // end change >>>
      ),
      body: body,
    );
  }

  Future<NotusDocument> _loadDocument() async {
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    if (await file.exists()) {
      final contents = await file.readAsString();
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("Write here\n");
    return NotusDocument.fromDelta(delta);
  }

  void _saveDocument(BuildContext context) {
    print('I am calling saved button !!!');
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      print('Contents of saved editor is : $contents');
      // Navigator.pop(context,file);
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });
  }

  void _sendDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");

    print('Sending File is  : $file ***********************************');
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Navigator.pop(context, file);
    });
  }
}
