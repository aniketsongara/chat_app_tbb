/*
// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zefyr/zefyr.dart';

/// Custom image delegate used by this example to load image from application
/// assets.
class CustomImageDelegate implements ZefyrImageDelegate<ImageSource> {
  final FirebaseStorage storage;

  CustomImageDelegate(this.storage);
  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;

  @override
  Future<String> pickImage(ImageSource source) async {
    final file = await ImagePicker.pickImage(source: source);
    if (file == null) return null;
    return file.uri.toString();
  }

  @override
  Widget buildImage(BuildContext context, String key) {
    // We use custom "asset" scheme to distinguish asset images from other files.
    if (key.startsWith('asset://')) {
      final asset = AssetImage(key.replaceFirst('asset://', ''));
      return Image(image: asset);
    } else {
      // Otherwise assume this is a file stored locally on user's device.
      final file = File.fromUri(Uri.parse(key));

      var img= file.readAsBytes().asStream();
      
      final image = FileImage(file);
      return Image(image: image);
    }
  }
}
*/

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zefyr/zefyr.dart';

class CustomImageDelegate extends ZefyrImageDelegate<ImageSource> {
  @override
  ImageSource get cameraSource => ImageSource.camera;

  @override
  ImageSource get gallerySource => ImageSource.gallery;

  @override
  Future<String> pickImage(ImageSource source) async {
    final imagePath = await ImagePicker.pickImage(source: source);
    if (imagePath == null) return null;

    Uri fileUri = Uri.parse(imagePath.path);
    final file = new File.fromUri(fileUri);
    String filename = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance.ref().child(filename);

    StorageUploadTask uploadTask =
        ref.putFile(file, StorageMetadata(contentType: 'image/jpeg'));

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    return getImageUrl(storageTaskSnapshot);
  }

  Future<String> getImageUrl(StorageTaskSnapshot snapshot) {
    return snapshot.ref.getDownloadURL().then((value) => value);
  }

  @override
  Widget buildImage(BuildContext context, String imageSource) {
    if (imageSource.startsWith('asset://')) {
      return Image.asset(imageSource.replaceFirst('asset://', ''));
    } else if (imageSource.startsWith('https://firebasestorage')) {
      return Image.network(imageSource);
    } else {
      return buildImage(context, imageSource);
    }
  }
}
