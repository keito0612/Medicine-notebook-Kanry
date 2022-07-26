import 'dart:convert';

import 'package:flutter/material.dart';

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
        body: SingleChildScrollView(
          child: Column(children: [
            Center(
              child: InteractiveViewer(
                  child: Image.memory(base64Decode(medicineImage!),
                      fit: BoxFit.fill)),
            ),
          ]),
        ),
      ),
    );
  }
}
