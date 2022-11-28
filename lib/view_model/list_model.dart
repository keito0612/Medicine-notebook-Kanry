import 'package:flutter/material.dart';
import 'package:medicine/Common/db_provider.dart';
import 'package:medicine/view/list_page.dart' as meunitem;
import 'package:medicine/model/medicine.dart';

class ListModel extends ChangeNotifier {
  bool loading = false;
  List<Medicine> medicineList = [];
  List<Medicine> searchList = [];

  Future getList() async {
    isLoading();
    final db = await DBProvider.db.database;
    var res = await db.query('medicine');
    //データの読み込み
    medicineList = res.map((data) => Medicine.toJson(data)).toList();
    isReloading();
    notifyListeners();
  }

  Future delete(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('medicine', where: "id = ?", whereArgs: [id]);
    notifyListeners();
  }

  void isLoading() {
    loading = true;
    notifyListeners();
  }

  void isReloading() {
    loading = false;
    notifyListeners();
  }

  List<String> imageList(List<String> imageList) {
    List<String> imageDataList = [];
    for (String imageData in imageList) {
      var image = imageData.replaceAll('[', "");
      image = image.replaceAll("]", "");
      image = image.trim();
      imageDataList.add(image);
    }
    return imageDataList;
  }

  void sortList(item) {
    if (item == meunitem.SortItem.oldItem) {
      final sortDataList = medicineList
        ..sort(((a, b) => a.id!.compareTo(b.id!)));
      medicineList = sortDataList;
    } else if (item == meunitem.SortItem.newItem) {
      final sortDataList = medicineList
        ..sort(((a, b) => b.id!.compareTo(a.id!)));
      medicineList = sortDataList;
    }
    notifyListeners();
  }

  //google広告用のバナーID
  String getTestAdBannerUnitId() {
    String testBannerUnitId = "";
    testBannerUnitId =
        "ca-app-pub-3940256099942544/2934735716"; // iOSのデモ用バナー広告ID
    return testBannerUnitId;
  }

  void search(String keyword) {
    if (keyword == "") {
      getList();
      notifyListeners();
    } else {
      searchList = medicineList
          .where((data) =>
              data.hospitalText!.contains(keyword) ||
              data.examinationText!.contains(keyword))
          .toList();
      notifyListeners();
    }
  }
}
