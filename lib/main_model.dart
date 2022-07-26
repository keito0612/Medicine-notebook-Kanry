import 'package:flutter/material.dart';
import 'package:medicine/db_provider.dart';
import 'package:medicine/main.dart' as meunitem;
import 'package:medicine/medicine.dart';

class MainModel extends ChangeNotifier {
  bool loading = false;
  List<Medicine> medicineList = [];
  List<Medicine> searchList = [];

  Future getList() async {
    final db = await DBProvider.db.database;
    var res = await db.query('medicine');
    print('data:$res');
    //データの読み込み
    medicineList = res.map((data) => Medicine.fromMap(data)).toList();
    searchList = medicineList;
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

  void search(String keyword) {
    if (keyword == "") {
      searchList;
      notifyListeners();
    } else {
      medicineList = searchList
          .where((data) =>
              data.hospitalText!.contains(keyword) ||
              data.examinationText!.contains(keyword))
          .toList();
      notifyListeners();
    }
  }
}
