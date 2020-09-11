import 'dart:io';
import 'package:chat_app_tbb/playvideo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zefyr/zefyr.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CustomVideoDelegate implements ZefyrVideoDelegate<ImageSource> {
  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;

  @override
  Future<String> pickVideo(ImageSource source) async {
    final file = await ImagePicker.pickVideo(source: source);
    if (file == null) return null;

    String filename = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance.ref().child(filename);

    StorageUploadTask uploadTask =
        ref.putFile(file, StorageMetadata(contentType: 'video/mp4'));

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    return getVideoUrl(storageTaskSnapshot);
  }

  Future<String> getVideoUrl(StorageTaskSnapshot snapshot) {
    return snapshot.ref.getDownloadURL().then((value) => value);
  }

  @override
  Widget buildVideo(BuildContext context, String key) {
    // We use custom "asset" scheme to distinguish asset video from other files.
    if (key.startsWith('asset://')) {
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
              child: Icon(
                Icons.video_library,
                size: 25,
              ),
            ),
            Expanded(child: Text('$key'))
          ],
        ),
        color: Color(0xff95975D),
      );
      //return File(key.replaceFirst('asset://', ''));
    } else if (key.startsWith('https://firebasestorage')) {
      return GestureDetector(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 5),
                child: IconButton(
                  icon: Icon(
                    Icons.video_library,
                    size: 25,
                  ),
                  onPressed: () {
                    print('Screen is tab !');
                  },
                ),
              ),
              Expanded(child: Text('Video Attached '))
            ],
          ),
          color: Color(0xff95975D),
        ),
        onTap: () {
          print('Screen is tab !');
        },
      );
    } else {
      return buildVideo(context, key);
    }
  }
}
