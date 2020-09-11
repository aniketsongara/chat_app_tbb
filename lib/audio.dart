import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefyr/zefyr.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'audio_recording_page.dart';

class CustomAudioDelegate implements ZefyrAudioDelegate {
  @override
  Future<String> pickAudio(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioRecordingScreen()),
    );
    final file = File.fromUri(Uri.parse(result));

    String filename = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance.ref().child(filename);

    StorageUploadTask uploadTask =
        ref.putFile(file, StorageMetadata(contentType: 'audio/mp3'));

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    return getAudioUrl(storageTaskSnapshot);
  }

  Future<String> getAudioUrl(StorageTaskSnapshot snapshot) {
    return snapshot.ref.getDownloadURL().then((value) => value);
  }

  @override
  Widget buildAudio(BuildContext context, String key) {
    if (key.startsWith('asset://')) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
              child: Icon(
                Icons.library_music,
                size: 25,
              ),
            ),
            Expanded(child: Text('Audio Attached'))
          ],
        ),
        color: Color(0xff95975D),
      );
    } else if (key.startsWith('https://firebasestorage')) {
      return GestureDetector(
        onTap: () {},
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                child: Icon(
                  Icons.library_music,
                  size: 25,
                ),
              ),
              Expanded(child: Text('Audio Attached'))
            ],
          ),
          color: Color(0xff95975D),
        ),
      );
    } else {
      return buildAudio(context, key);
    }
  }
}
