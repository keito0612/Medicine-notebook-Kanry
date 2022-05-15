import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medicine/base_helper.dart';
import 'package:medicine/db_provider.dart';
import 'package:medicine/file_conroller.dart';
import 'package:medicine/medicine.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite/sql.dart';

class AddModel extends ChangeNotifier {
  String hospitalText = "";
  String examinationText = "";
  File? imageFile;
  File? image;
  XFile? pickedFile;

  //カメラの起動
  Future getImagecamera() async {
    final picker = ImagePicker();
    pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      imageFile = await FileController.getImagePath(pickedFile!);
    }
    notifyListeners();
  }

  //時間を取得する
  String getTime() {
    initializeDateFormatting('jp');
    final now = DateTime.now();
    final time = DateFormat.yMMMd('ja').format(now);
    return time;
  }

  //追加
  Future add() async {
    if (imageFile == null) {
      throw ('写真が取られていません');
    }
    if (examinationText.isEmpty && hospitalText.isEmpty) {
      throw ('病院名と診察科目を入力してください');
    } else if (examinationText.isEmpty) {
      throw ('病院名を入力してください');
    } else if (hospitalText.isEmpty) {
      throw ('診療科目を入力してください');
    }

    //DBへ保存するため、base64文字列へ変換する
    var _base64ImageString =
        Base64Helper().base64String(imageFile!.readAsBytesSync());

    final medicineSave = Medicine(
        hospitalText: hospitalText,
        examinationText: examinationText,
        image: _base64ImageString,
        time: getTime());
    //データベースに保存する
    insert(medicineSave);
    notifyListeners();
  }

  Future<void> insert(Medicine medicine) async {
    final db = await DBProvider.db.database;
    await db.insert('medicine', medicine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
