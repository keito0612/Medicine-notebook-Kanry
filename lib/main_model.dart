import 'package:flutter/material.dart';
import 'package:medicine/db_provider.dart';
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
