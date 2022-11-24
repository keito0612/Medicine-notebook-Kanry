import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medicine/calendar_edit_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CalendarEditPage extends StatelessWidget {
  CalendarEditPage(this.id, this.notificationId, this.titleText, this.timeText,
      this.memoText, this.isOn, this.notificationTime);

  final int id;
  final int notificationId;
  final String titleText;
  final String timeText;
  final String memoText;
  final int isOn;
  final String notificationTime;

  final notificationTimebars = [
    '１５分',
    '３０分',
    '１時間',
    '２時間',
    '３時間',
    '４時間',
    '５時間',
    '６時間',
    '１日',
    '２日',
    '３日'
  ];
  final selectTime = DateTime.now();
  final todayTime = DateTime.now();
  final dateFormat = DateFormat('yyyy/MM/dd(E) HH:mm', "ja");
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CalendarEditModel>(
      create: (_) => CalendarEditModel(
          id: id,
          notificationId: notificationId,
          titleText: titleText,
          timeText: timeText,
          memoText: memoText,
          isOn: isOn == 1 ? true : false,
          notificationTime: notificationTime),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 224, 234),
        appBar: AppBar(
          title: const Text('編集'),
          backgroundColor: Colors.pink[100],
        ),
        body: Consumer<CalendarEditModel>(
          builder: (context, model, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          //タイトル
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            width: 350,
                            height: 60,
                            child: Row(
                              children: <Widget>[
                                const SizedBox(width: 10),
                                const Icon(Icons.edit),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 300,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.pink.shade100),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: TextField(
                                      controller: model.titleTextController,
                                      style: const TextStyle(
                                        fontSize: 13,
                                      ),
                                      decoration: const InputDecoration(
                                        hintText: 'タイトル',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (text) {
                                        model.setTitleText(text);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          //日時
                          InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    height: 250,
                                    child: Column(
                                      children: [
                                        TextButton(
                                          child: const Text('閉じる'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            minimumDate: DateTime.now()
                                                .subtract(
                                                    const Duration(days: 1)),
                                            initialDateTime: selectTime,
                                            use24hFormat: true,
                                            mode: CupertinoDatePickerMode
                                                .dateAndTime,
                                            onDateTimeChanged: (dateTime) {
                                              model.settingTime(dateTime);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                                width: 350,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(children: <Widget>[
                                  const SizedBox(width: 10),
                                  const Icon(Icons.calendar_month),
                                  const SizedBox(width: 20),
                                  Text('日時:${model.timeText}'),
                                ])),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      //通知設定枠線
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            '通知設定',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 3,
                            width: 270,
                            color: const Color.fromARGB(255, 190, 184, 184),
                          ),
                        ],
                      ),
                      //通知ボタン
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          const Text('通知',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          const SizedBox(width: 20),
                          CupertinoSwitch(
                            value: model.isOn!,
                            onChanged: (bool value) {
                              model.onChecked(value);
                            },
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      //通知設定
                      model.isOn == true
                          ? InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 250,
                                      child: Column(
                                        children: [
                                          TextButton(
                                            child: const Text('閉じる'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          Expanded(
                                            child: CupertinoPicker(
                                              itemExtent: 30,
                                              children: notificationTimebars
                                                  .map((timebars) =>
                                                      Text("$timebars前"))
                                                  .toList(),
                                              onSelectedItemChanged:
                                                  (int index) {
                                                model.settingNotification(
                                                    notificationTimebars[
                                                        index]);
                                              },
                                              //開始位置を選択
                                              scrollController:
                                                  FixedExtentScrollController(
                                                initialItem: 0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 350,
                                height: 60,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: <Widget>[
                                    const SizedBox(width: 10),
                                    const Icon(Icons.notifications),
                                    const SizedBox(width: 20),
                                    Text(
                                      ' 通知：${model.notificationTime}',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              width: 350,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: const <Widget>[
                                  SizedBox(width: 10),
                                  SizedBox(width: 20),
                                  Text('通知',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              222, 244, 244, 244))),
                                ],
                              ),
                            ),
                      const SizedBox(height: 30),
                      //枠線
                      Container(
                        height: 3,
                        width: 350,
                        color: const Color.fromARGB(255, 190, 184, 184),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      // メモ枠線
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            'メモ欄',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Container(
                            height: 3,
                            width: 285,
                            color: const Color.fromARGB(255, 190, 184, 184),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      //メモ欄
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        height: 60,
                        width: 350,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: TextField(
                            controller: model.memoTextController,
                            onChanged: (text2) {
                              model.setMemoText(text2);
                            },
                            decoration: const InputDecoration(
                              hintText: 'メモ',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      //枠線
                      Container(
                        height: 3,
                        width: 350,
                        color: const Color.fromARGB(255, 190, 184, 184),
                      ),
                      const SizedBox(height: 40),
                      //追加ボタン
                      SizedBox(
                        height: 50,
                        width: 200,
                        child: ElevatedButton(
                            child: const Text('更新'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[100],
                            ),
                            onPressed: () async {
                              //お薬手帳を追加する
                              await updateDialog(model, context);
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// 追加ダイアログ
Future updateDialog(CalendarEditModel model, BuildContext context) async {
  try {
    await model.update();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('更新しました。'),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    Navigator.of(context).pop();
  } catch (e) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
