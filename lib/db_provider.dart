import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  // privateなコンストラクタ
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB();
      return _database!;
    }
  }

  Future<Database> initDB() async {
    //データベースを作成
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "medicineDB.db");
    final Future<Database> _database = openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
            // テーブルの作成
            "CREATE TABLE medicine (id INTEGER PRIMARY KEY AUTOINCREMENT,hospitalText TEXT ,examinationText TEXT,time TEXT,image TEXT)");
      },
      version: 1,
    );
    return _database;
  }
}
