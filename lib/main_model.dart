import 'package:flutter/material.dart';
import 'package:medicine/db_provider.dart';
import 'package:medicine/main.dart';
import 'package:medicine/medicine.dart';

class MainModel extends ChangeNotifier {
  List<Medicine> medicineList = [];
  List<Medicine> searchList = [];
  Future getList() async {
    final db = await DBProvider.db.database;
    var res = await db.query('medicine');
    print('data:$res');
    //データの読み込み
    medicineList = res.map((data) => Medicine.fromMap(data)).toList();
    notifyListeners();
  }

  Future delete(int id) async {
    final db = await DBProvider.db.database;
    await db.delete('medicine', where: "id = ?", whereArgs: [id]);
    notifyListeners();
  }

  void sortList(MenuItem item) {
    if (item == MenuItem.item1) {
      final sortDataList = medicineList
        ..sort(((a, b) => a.id!.compareTo(b.id!)));
      medicineList = sortDataList;
    } else if (item == MenuItem.item2) {
      final sortDataList = medicineList
        ..sort(((a, b) => b.id!.compareTo(a.id!)));
    }
    notifyListeners();
  }

  void search(String keyword) {
    if (keyword == "") {
      searchList = medicineList;
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
