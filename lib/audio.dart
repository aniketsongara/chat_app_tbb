
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefyr/zefyr.dart';

import 'audio_recording_page.dart';

class CustomAudioDelegate implements ZefyrAudioDelegate {

  @override
  Future<String> pickAudio(BuildContext context) async {
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => AudioRecordingScreen()),
    );
    return result;
  }

  @override
  Widget buildAudio(BuildContext context, String key) {
    // We use custom "asset" scheme to distinguish asset images from other files.
    if (key.startsWith('asset://')) {
      final asset = AssetImage(key.replaceFirst('asset://', ''));
      return Image(image: asset);
    } else {
      // Otherwise assume this is a file stored locally on user's device.
      final file = File.fromUri(Uri.parse(key));
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
            Expanded(child: Text('${file.path}'))
          ],
        ),
        color: Color(0xff95975D),
      );
    }
  }
}
