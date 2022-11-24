import 'package:flutter/material.dart';
import 'package:medicine/db_provider.dart';
import 'package:medicine/event.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';
import "package:intl/intl.dart";
import 'dart:math';
import 'package:timezone/timezone.dart' as tz;

class CalendarAddModel extends ChangeNotifier {
  String titleText = '';
  String memoText = '';
  DateTime _time = DateTime.now();
  bool isOn = false;
  String notificationTime = '１５分前';
  String timeText = '';
  List<int>? notificationIdList;
  int? notificationId;
  final formatter = DateFormat('yyyy/MM/dd(E) HH:mm', "ja");

  void onChecked(bool value) {
    isOn = value;
    notifyListeners();
  }

  Future getNotificationId() async {
    notificationId = Random().nextInt(10000);
    final db = await DBProvider.db.database;
    var res = await db.query('event');
    notificationIdList != null
        ? res.map((data) => Event.fromMap(data).notificationId!).toList()
        : null;
    if (notificationIdList == null) return;
    //通知IDが同じ物だったらその都度新しいIDを設定する。
    while (notificationIdList!
        .any((notificationId) => notificationId == notificationId)) {
      notificationId = Random().nextInt(10000);
    }
  }

  void settingTime(DateTime dateTime) {
    initializeDateFormatting("ja_JP");
    _time = dateTime;
    final time = formatter.format(dateTime);
    timeText = time;
    notifyListeners();
  }

  //通知時間を設定する。
  void settingNotification(String notificationTimebars) {
    notificationTime = "$notificationTimebars前";
    notifyListeners();
  }

  void selectionNotificationTime(String notificationTime) {
    switch (notificationTime) {
      case '１５分前':
        _time = _time.add(const Duration(minutes: 15) * -1);
        break;
      case '３０分前':
        _time = _time.add(const Duration(minutes: 30) * -1);
        break;
      case '１時間前':
        _time = _time.add(const Duration(hours: 1) * -1);
        break;
      case '２時間前':
        _time = _time.add(const Duration(hours: 2) * -1);
        break;
      case '1日前':
        _time = _time.add(const Duration(days: 1) * -1);
        break;
      case '2日前':
        _time = _time.add(const Duration(days: 2) * -1);
        break;
      default:
    }
  }

  Future _setNotify({int? id, DateTime? time}) async {
    final scheduleTime = tz.TZDateTime(
        tz.local, time!.year, time.month, time.day, time.hour, time.minute);
    final now = DateTime.now();
    final presentTime = formatter.format(now);
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);
    NotificationDetails platformChannelSpecifics = const NotificationDetails(
      iOS: iOSPlatformChannelSpecifics,
      android: null,
    );
    if (scheduleTime.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
          id!,
          'お薬手アプリKanry',
          '${notificationTime.replaceAll("前", "")}後に以下の予定があります。\n$titleText',
          scheduleTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  Future add() async {
    if (titleText == '') {
      throw ('タイトルが入力されていません');
    }
    if (timeText == '') {
      throw ('日時が設定されていません');
    }
    if (isOn == true) {
      selectionNotificationTime(notificationTime);
      await getNotificationId();
      await _setNotify(id: notificationId, time: _time);
    }
    final calendarSave = Event(
        notificationId: notificationId,
        titleText: titleText,
        timeText: timeText,
        memoText: memoText,
        isOn: isOn ? 1 : 0,
        notificationTime: isOn ? notificationTime : "");
    //データベースに保存する
    await _insert(calendarSave);
  }

  Future _insert(Event event) async {
    final db = await DBProvider.db.database;
    await db.insert('event', event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
