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
import 'package:image_cropper/image_cropper.dart';

class AddModel extends ChangeNotifier {
  String hospitalText = "";
  String examinationText = "";
  File? imageFile;
  XFile? _pickedFile;
  XFile? _croppedImageFile;
  dynamic base64ImageString;

  //カメラの起動
  Future getImagecamera() async {
    final picker = ImagePicker();
    _pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (_pickedFile != null) {
      imageFile = await FileController.getImagePath(_pickedFile!);
      //切り取る予定の写真を入れる
      _croppedImageFile = _pickedFile;
      await _cropImage(_croppedImageFile!);
      imageFile = await FileController.getImagePath(_croppedImageFile!);
    }
    //DBへ保存するため、base64文字列へ変換する
    base64ImageString =
        Base64Helper().base64String(imageFile!.readAsBytesSync());
    notifyListeners();
  }

  //画像を切り取る
  Future _cropImage(XFile croppedImageFile) async {
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: croppedImageFile.path,
      uiSettings: [
        IOSUiSettings(
            hidesNavigationBar: false,
            aspectRatioPickerButtonHidden: false,
            doneButtonTitle: "次へ",
            cancelButtonTitle: "キャンセル"),
      ],
      cropStyle: CropStyle.rectangle,
    );
    if (croppedFile != null) {
      _croppedImageFile = XFile(croppedFile.path);
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

    final medicineSave = Medicine(
        hospitalText: hospitalText,
        examinationText: examinationText,
        image: base64ImageString,
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
