import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:medicine/base_helper.dart';
import 'package:medicine/calendar.dart';
import 'package:medicine/edit_page.dart';
import 'package:medicine/main_model.dart';
import 'package:medicine/medicine.dart';
import 'package:medicine/photo.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'add_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, //縦固定
  ]);
  tz.initializeTimeZones();
  await _configureLocalTimeZone();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: true,
    requestAlertPermission: true,
  );
  //initializationSettingsのオブジェクト作成
  const InitializationSettings initializationSettings = InitializationSettings(
    iOS: initializationSettingsIOS,
    android: null,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  runApp(MainApp());
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class MainApp extends StatefulWidget {
  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  // This widget is the root of your application.
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _selectedPage = [ListPage(), CalendarPage()];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'お薬手帳リスト',
      theme: ThemeData(
        backgroundColor: Colors.pink[100],
      ),
      home: Scaffold(
        body: _selectedPage[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          unselectedLabelStyle:
              const TextStyle(color: Colors.white, fontSize: 14),
          fixedColor: Colors.pink[100],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'リスト',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'カレンダー',
            ),
          ],
        ),
      ),
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

enum SortItem {
  newItem,
  oldItem,
}

class ListPage extends StatelessWidget {
  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainModel>(
        create: (_) => MainModel()..getList(),
        child: Consumer<MainModel>(builder: (context, model, child) {
          return Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: const Text('お薬手帳リスト'),
                  backgroundColor: Colors.pink[100],
                  actions: [
                    PopupMenuButton<SortItem>(
                        icon: const Icon(Icons.sort),
                        onSelected: (value) {
                          if (value == SortItem.oldItem) {
                            model.sortList(value);
                          } else if (value == SortItem.newItem) {
                            model.sortList(value);
                          }
                        },
                        itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: SortItem.oldItem, child: Text('古い順')),
                              PopupMenuItem(
                                  value: SortItem.newItem, child: Text('新しい順'))
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
                                        elevation: 20.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Slidable(
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              //削除ボタン
                                              SlidableAction(
                                                  flex: 1,
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: '削除',
                                                  onPressed: (BuildContext
                                                      context) async {
                                                    await deleteDialog(model,
                                                        context, medicine);
                                                  }),
                                              //編集ボタン
                                              SlidableAction(
                                                flex: 1,
                                                backgroundColor: Colors.brown,
                                                foregroundColor: Colors.white,
                                                icon: Icons.edit,
                                                label: '編集',
                                                onPressed: (BuildContext
                                                    context) async {
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => EditPage(
                                                          medicine
                                                              .hospitalText!,
                                                          medicine
                                                              .examinationText!,
                                                          medicine.image!,
                                                          medicine.id!),
                                                      fullscreenDialog: true,
                                                    ),
                                                  );
                                                  model.isLoading();
                                                  await model.getList();
                                                  model.isReloading();
                                                },
                                              )
                                            ],
                                          ),
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            tileColor: Colors.pink[100],
                                            //リストに画像を表示する。
                                            leading: InkWell(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          Photo(
                                                              medicineImage:
                                                                  medicine
                                                                      .image),
                                                      fullscreenDialog: true,
                                                    ),
                                                  );
                                                  model.isLoading();
                                                  await model.getList();
                                                  model.isReloading();
                                                },
                                                child: medicine.image != null
                                                    ? SizedBox(
                                                        width: 45,
                                                        height: 50,
                                                        child: Base64Helper()
                                                            .imageFromBase64String(
                                                                medicine
                                                                    .image!))
                                                    : Container(
                                                        width: 45,
                                                        height: 50,
                                                        color: Colors.grey)),
                                            title: Text(
                                                '病院名:${medicine.hospitalText}\n診察科目:${medicine.examinationText}\n日付:${medicine.time}'),
                                            textColor: Colors.white,
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
                                        child: Slidable(
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          //削除ボタン
                                          SlidableAction(
                                              flex: 1,
                                              backgroundColor: Colors.red,
                                              foregroundColor: Colors.white,
                                              icon: Icons.delete,
                                              label: '削除',
                                              onPressed:
                                                  (BuildContext context) async {
                                                await deleteDialog(
                                                    model, context, medicine);
                                              }),
                                          //編集ボタン
                                          SlidableAction(
                                            flex: 1,
                                            backgroundColor: Colors.brown,
                                            foregroundColor: Colors.white,
                                            icon: Icons.edit,
                                            label: '編集',
                                            onPressed:
                                                (BuildContext context) async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditPage(
                                                          medicine
                                                              .hospitalText!,
                                                          medicine
                                                              .examinationText!,
                                                          medicine.image!,
                                                          medicine.id!),
                                                  fullscreenDialog: true,
                                                ),
                                              );
                                              model.isLoading();
                                              await model.getList();
                                              model.isReloading();
                                            },
                                          )
                                        ],
                                      ),
                                      child: ListTile(
                                        tileColor: Colors.pink[100],
                                        //リストに画像を表示する。
                                        leading: InkWell(
                                            onTap: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Photo(
                                                    medicineImage:
                                                        medicine.image,
                                                  ),
                                                  fullscreenDialog: true,
                                                ),
                                              );
                                              model.isLoading();
                                              await model.getList();
                                              model.isReloading();
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
                        ).then((e) async {
                          //画面が戻ったら処理が発動する
                          model.isLoading();
                          await model.getList();
                          model.isReloading();
                        });
                      },
                      tooltip: '追加する',
                      child: const Icon(Icons.add),
                    );
                  },
                ),
              ),
              if (model.loading) showIndicator(context)
            ],
          );
        }));
  }

  //インジゲータ
  Widget showIndicator(BuildContext context) {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
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
                onPressed: () async {
                  Navigator.pop(context);
                })
          ],
        );
      },
    );
  }
}
