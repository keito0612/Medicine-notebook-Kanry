import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medicine/base_helper.dart';
import 'package:medicine/edit_page.dart';
import 'package:medicine/main_model.dart';
import 'package:medicine/medicine.dart';
import 'package:medicine/photo.dart';
import 'package:provider/provider.dart';

import 'add_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, //縦固定
  ]);
  runApp(ListApp());
}

enum MenuItem {
  item1,
  item2,
}

class ListApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'お薬手帳リスト',
      theme: ThemeData(
        backgroundColor: Colors.pink[100],
      ),
      home: ListHome(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale("ja"),
      ],
    );
  }
}

class ListHome extends StatelessWidget {
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainModel>(
        create: (_) => MainModel()..getList(),
        child: Consumer<MainModel>(builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('お薬手帳リスト'),
              backgroundColor: Colors.pink[100],
              actions: [
                PopupMenuButton<MenuItem>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) {
                      if (value == MenuItem.item1) {
                        model.sortList(value);
                      } else if (value == MenuItem.item2) {
                        model.sortList(value);
                      }
                    },
                    itemBuilder: (context) => const [
                          PopupMenuItem(
                              value: MenuItem.item1, child: Text('日付が小さい順')),
                          PopupMenuItem(
                              value: MenuItem.item2, child: Text('日付が大きい順'))
                        ]),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (_seartchText) {
                      searchText = _seartchText;
                      model.search(searchText);
                    },
                    decoration: const InputDecoration(
                      hintText: "病院名または診察科目を検索",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(25.0))),
                    ),
                  ),
                ),
                Consumer<MainModel>(builder: (context, model, child) {
                  if (searchText == "") {
                    return Expanded(
                      child: ListView(
                          children: model.medicineList
                              .map(
                                (medicine) => Card(
                                    child: ListTile(
                                  tileColor: Colors.pink[100],
                                  //リストに画像を表示する。
                                  leading: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Photo(
                                                medicineImage: medicine.image),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                        model.getList();
                                      },
                                      child: medicine.image != null
                                          ? SizedBox(
                                              width: 45,
                                              height: 50,
                                              child: Base64Helper()
                                                  .imageFromBase64String(
                                                      medicine.image!))
                                          : Container(
                                              width: 45,
                                              height: 50,
                                              color: Colors.grey)),
                                  title: Text(
                                      '病院名:${medicine.hospitalText}\n診察科目:${medicine.examinationText}\n日付:${medicine.time}'),
                                  textColor: Colors.white,
                                  onLongPress: () async {
                                    //削除
                                    await deleteDialog(
                                        model, context, medicine);
                                  },
                                  //編集ボタン
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPage(
                                              medicine.hospitalText!,
                                              medicine.examinationText!,
                                              medicine.image!,
                                              medicine.id!),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                      model.getList();
                                    },
                                  ),
                                )),
                              )
                              .toList()),
                    );
                  } else {
                    return Expanded(
                      child: ListView(
                          children: model.searchList
                              .map(
                                (medicine) => Card(
                                    child: ListTile(
                                  tileColor: Colors.pink[100],
                                  //リストに画像を表示する。
                                  leading: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Photo(
                                              medicineImage: medicine.image,
                                            ),
                                            fullscreenDialog: true,
                                          ),
                                        );
                                        model.getList();
                                      },
                                      //写真
                                      child: medicine.image != null
                                          ? SizedBox(
                                              width: 45,
                                              height: 50,
                                              child: Base64Helper()
                                                  .imageFromBase64String(
                                                      medicine.image!))
                                          : Container(
                                              width: 45,
                                              height: 50,
                                              color: Colors.grey)),
                                  title: Text(
                                      '病院名:${medicine.hospitalText}\n診察科目:${medicine.examinationText}\n日付:${medicine.time}'),
                                  textColor: Colors.white,
                                  onLongPress: () async {
                                    //削除
                                    await deleteDialog(
                                        model, context, medicine);
                                  },
                                  //編集ボタン
                                  trailing: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditPage(
                                              medicine.hospitalText!,
                                              medicine.examinationText!,
                                              medicine.image!,
                                              medicine.id!),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                      model.getList();
                                    },
                                  ),
                                )),
                              )
                              .toList()),
                    );
                  }
                }),
              ],
            ),
            floatingActionButton: Consumer<MainModel>(
              builder: (context, model, child) {
                return FloatingActionButton(
                  backgroundColor: Colors.pink[100],
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddPage(),
                        fullscreenDialog: true,
                      ),
                    ).then((e) {
                      //画面が戻ったら処理が発動する
                      model.getList();
                    });
                  },
                  tooltip: '追加する',
                  child: const Icon(Icons.add),
                );
              },
            ),
          );
        }));
  }

  //削除ダイアログ
  Future deleteDialog(
      MainModel model, BuildContext context, Medicine medicine) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('削除しますか?'),
          actions: <Widget>[
            TextButton(
              child: const Text("はい"),
              onPressed: () async {
                await model.delete(medicine.id!);
                await model.getList();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('いいえ'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
