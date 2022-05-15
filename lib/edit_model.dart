import 'package:flutter/material.dart';
import 'package:medicine/base_helper.dart';
import 'package:medicine/db_provider.dart';
import 'package:medicine/file_conroller.dart';
import 'package:medicine/medicine.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:sqflite/sqlite_api.dart';

class EditModel extends ChangeNotifier {
  EditModel(this.hospitalText, this.examinationText, this.image, this.id) {
    textController.text = hospitalText!;
    textController2.text = examinationText!;
  }
  final textController = TextEditingController();
  final textController2 = TextEditingController();
  String? hospitalText;
  String? examinationText;
  String? image;
  int? id;
  File? imageFile;
  XFile? pickedFile;

  //カメラの起動
  Future getImagecamera() async {
    final picker = ImagePicker();
    pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFile = await FileController.getImagePath(pickedFile!);
      final baseImage =
          Base64Helper().base64String(imageFile!.readAsBytesSync());
      image = baseImage;
    }
    notifyListeners();
  }

  void setHospitalText(String hospitalText) {
    this.hospitalText = hospitalText;
    notifyListeners();
  }

  void setExaminationText(String examinationText) {
    this.examinationText = examinationText;
    notifyListeners();
  }

  bool isUpdated() {
    return hospitalText != null || examinationText != null;
  }

  //現在の時間を取得
  String getTime() {
    initializeDateFormatting('jp');
    final now = DateTime.now();
    final time = DateFormat.yMMMd('ja').format(now);
    return time;
  }

  //更新
  Future update() async {
    hospitalText = textController.text;
    examinationText = textController2.text;

    final updeteData = Medicine(
        id: id,
        hospitalText: hospitalText,
        examinationText: examinationText,
        image: image,
        time: getTime());

    await _update(updeteData);
    notifyListeners();
  }

  Future _update(Medicine medicine) async {
    final db = await DBProvider.db.database;
    await db.update('medicine', medicine.toMap(),
        where: "id = ?",
        whereArgs: [medicine.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
