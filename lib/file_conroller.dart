import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class FileController {
  static Future get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future getCroppedImagePath(File croppedImageFile) async {
    final imageFile = File(croppedImageFile.path);
    //ストレージパス取得
    final path = await localPath;
    //撮った写真のパスをpng形式にする
    final imagePath = '$path/medicine.png';
    final copiedImageFile = await imageFile.copy(imagePath);
    return copiedImageFile;
  }

  static Future getImagePath(XFile pickedFile) async {
    final imageFile = File(pickedFile.path);
    //ストレージパス取得
    final path = await localPath;
    //撮った写真のパスをpng形式にする
    final imagePath = '$path/medicine.png';
    final copiedImageFile = await imageFile.copy(imagePath);
    return copiedImageFile;
  }
}
