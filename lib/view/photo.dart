import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class Photo extends StatelessWidget {
  Photo({this.medicineImage});
  String? medicineImage;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.pink[100],
            appBar: AppBar(
              title: const Text('写真'),
              backgroundColor: Colors.pink[100],
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
            ),
            body: Container(
              child: PhotoView(
                  imageProvider: MemoryImage(base64Decode(medicineImage!))),
            )));
  }

  Widget showIndicator(BuildContext context) {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
