import 'audio.dart';
import 'images.dart';
import 'video.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';
import 'package:notustohtml/notustohtml.dart';

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


  var dir;

  Future<void> createDirectory() async {
    dir = await getExternalStorageDirectory();
    final myDir = Directory('${dir.path}/TBB');
    await myDir.exists().then((isThere) {
      if (!isThere) {
        Directory('${dir.path}/TBB').create(recursive: true)
        // The created directory is returned as a Future.
            .then((Directory directory) {
          print(
              '-------------------${directory.path}--------------------------');
        });
      } else {
        print('_________exists_______________________');
      }
    });
  }

  Future<NotusDocument> downloadFile(String url) async {
    await createDirectory();
    print('Coming in downloadFile function !');
    var dir = await getExternalStorageDirectory();

    final http.Response downloadData = await http.get(url);
    final file = File(dir.path + '/TBB/' + "/tmp.json");
    if (file.existsSync()) {
      await file.delete();
    }
    await file.create();
    file.writeAsString(downloadData.body).then((_) {
      // Navigator.pop(context,file);
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });

    print('Json body : ${downloadData.body}');

    //if (file != null) {
      final contents = await file.readAsString();

      print(NotusDocument.fromJson(jsonDecode(contents.replaceAll("â", "​"))));
      return NotusDocument.fromJson(jsonDecode(contents.replaceAll("â", "​")));
    //}
   // return NotusDocument.fromJson(jsonDecode(downloadData.body));
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
    var dir = await getExternalStorageDirectory();

    final file = File(dir.path + '/TBB/' + "/quick_start.json");

    String html = '<p>historically an orphanage is a residential institution or group home devoted to the care of orphans and other children who were separated from their orphanage is an institution dedicated to the care of orphans orphanage or the orphanage may also refer to the orphanage company california visual the orphanage spanish el orfanato is a 2007 spanish supernatural horror film and the debut feature of spanish filmmaker j a bayona the film starsthis was disputed by the orphanage trust and finally the wakf board and the orphanage came to an agreement the sale proceeded and the building was builtgore orphanage is the subject of a local legend in northern ohio which refers to a supposedly haunted ruin near the city of vermilion in lorain countyshades of a blue orphanage is the second studio album by irish band thin lizzy released in 1972 the title is a combination of the members previous bands the orphanage is a 2019 danishafghan drama film directed by shahrbanoo sadat it was screened in the directors fortnight section at the 2019 cannes the actors orphanage was started in 1896 by kittie carson at croydon and was established as the actors orphanage fund in 1912 in 1915 the orphanage the orphanage was a visual effects studio located in california it had offices in los angeles and san francisco it was cofounded in 1999 by stu maschwitz the mount cashel orphanage kl was an orphanage that was operated by the congregation of christian brothers in st johns newfoundland and labrador</p><p><br></p><p><img src="asset://images/img_not_available.jpeg" style="width: 100%;" class="fr-fil fr-dib"></p><p><span class="fr-video fr-fvc fr-dvb fr-draggable" contenteditable="false" draggable="true"><iframe src="//www.youtube.com/embed/W2Z7fbCLSTw?wmode=opaque" allowfullscreen="" width="640" height="360" frameborder="0"></iframe></span><br></p>';
    Delta delta11 = converter.decode(html); // Zefyr compatible Delta
    print('Html to notus data is : ');
    print(NotusDocument.fromDelta(delta11));


    if (await file.exists()) {
      final contents = await file.readAsString();
      print(NotusDocument.fromJson(jsonDecode(contents)));
      return NotusDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("Write here\n");
    return NotusDocument.fromDelta(delta);
  }
  final converter = NotusHtmlCodec();

  void _saveDocument(BuildContext context) async {

    await createDirectory();
    print('I am calling saved button !!!');
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    print('Controller of saved editor is : ${_controller.document}');
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.

    var dir = await getExternalStorageDirectory();

    final file = File(dir.path + '/TBB/' + "/quick_start.json");
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      print('Contents of saved editor is : $contents');
      // Navigator.pop(context,file);
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Saved.")));
    });

    String html = converter.encode(_controller.document.toDelta());
    print(html);
  }

  void _sendDocument(BuildContext context) async {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly
    await createDirectory();

    var dir = await getExternalStorageDirectory();

    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(dir.path + '/TBB/' + "/quick_start.json");

    print('Sending File is  : $file ***********************************');
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Navigator.pop(context, file);
    });
  }
}
