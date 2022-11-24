import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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
  EditModel(this.hospitalText, this.examinationText, this.base64ImageStringList,
      this.id) {
    textController.text = hospitalText!;
    textController2.text = examinationText!;
  }
  final textController = TextEditingController();
  final textController2 = TextEditingController();
  String? hospitalText;
  String? examinationText;
  File? imageFile;
  int? id;
  XFile? _croppedImageFile;
  List<String>? base64ImageStringList;
  XFile? _pickedFile;
  int current = 0;

  //カメラ
  Future getImageCamera(int? index) async {
    final picker = ImagePicker();
    _pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (_pickedFile != null) {
      //撮った写真を撮り直している
      if (index != null) {
        //DBに保存するために保存先のパスを作る
        imageFile = await FileController.getImagePath(_pickedFile!);
        //DBへ保存するため、base64文字列へ変換する
        base64ImageStringList![index] =
            Base64Helper().base64String(imageFile!.readAsBytesSync());
      } else {
        //あたらしい写真を取得して、保存先のパスを作る
        imageFile = await FileController.getImagePath(_pickedFile!);

        base64ImageStringList!
            .add(Base64Helper().base64String(imageFile!.readAsBytesSync()));
      }
      //切り取る予定の写真を入れる
      _croppedImageFile = _pickedFile;
      //画像を切りとる
      await _cropImage(_croppedImageFile!);
      //切り終えた画像を入れる
      if (index != null) {
        //切り終えた画像をDBに保存するために保存先のパスを作る
        imageFile = await FileController.getImagePath(_croppedImageFile!);
        //切り終えた画像をDBに保存するために保存先のパスを作る
        base64ImageStringList![index] =
            Base64Helper().base64String(imageFile!.readAsBytesSync());
      } else {
        imageFile = await FileController.getImagePath(_croppedImageFile!);
        base64ImageStringList!.last =
            Base64Helper().base64String(imageFile!.readAsBytesSync());
      }
      notifyListeners();
    }
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

  void setHospitalText(String hospitalText) {
    this.hospitalText = hospitalText;
    notifyListeners();
  }

  void setExaminationText(String examinationText) {
    this.examinationText = examinationText;
    notifyListeners();
  }

  void onPageIndex(int index) {
    current = index;
    notifyListeners();
  }

  List<String> imageList(List<String> base64ImageStringList) {
    List<String> imageDataList = [];
    for (String imageData in base64ImageStringList) {
      var image = imageData.replaceAll('[', "");
      image = image.replaceAll("]", "");
      image = image.trim();
      imageDataList.add(image);
    }
    return imageDataList;
  }

  //現在の時間を取得
  String getTime() {
    initializeDateFormatting('jp');
    final now = DateTime.now();
    final time = DateFormat('yyyy/MM/dd(E) HH:mm', "ja").format(now);
    return time;
  }

  //更新
  Future update() async {
    hospitalText = textController.text;
    examinationText = textController2.text;

    final updateData = Medicine(
        id: id,
        hospitalText: hospitalText,
        examinationText: examinationText,
        image: base64ImageStringList.toString(),
        time: getTime());

    await _update(updateData);
    notifyListeners();
  }

  Future _update(Medicine medicine) async {
    final db = await DBProvider.db.database;
    await db.update('medicine', medicine.fromMap(),
        where: "id = ?",
        whereArgs: [medicine.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
