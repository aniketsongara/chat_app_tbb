

import 'audio.dart';
import 'const.dart';
import 'images.dart';
import 'video.dart';


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
    _loadDocument().then((document) {
      setState(() {
        _controller = ZefyrController(document);
      });
    });
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
        mode: widget.serverFile!=null ? ZefyrMode.select : _editing ? ZefyrMode.edit : ZefyrMode.select,
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
          Visibility(child: Builder(
            builder: (context) => IconButton(
              icon: done,
              onPressed: () => _saveDocument(context),
            ),
          ),visible: widget.serverFile!=null ? false : true ,),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.send),
              onPressed: () => _sendeDocument(context),
            ),
          )
        ],
        // end change >>>
      ),
      body: body,
    );
  }


  Future<NotusDocument> _loadDocument() async {

    if(widget.serverFile!=null){
     // var _json = json.decode(widget.serverFile);
      //return  NotusDocument.fromJson(_json);
      final contents = await widget.serverFile;
      return NotusDocument.fromJson(jsonDecode(contents));
    }else{
      final file = File(Directory.systemTemp.path + "/quick_start.json");
      if (await file.exists()) {
        final contents = await file.readAsString();
        return NotusDocument.fromJson(jsonDecode(contents));
      }
    }
    final Delta delta = Delta()..insert("Write here\n");
    return NotusDocument.fromDelta(delta);
  }


  void _saveDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Navigator.pop(context,file);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });
  }

  void _sendeDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + "/quick_start.json");

    print('Sending File is  : $file ***********************************');
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Navigator.pop(context,file);
    });
  }


}


