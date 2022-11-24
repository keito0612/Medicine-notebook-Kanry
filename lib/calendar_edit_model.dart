import 'dart:math';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:medicine/db_provider.dart';
import 'package:medicine/event.dart';
import 'package:sqflite/sqflite.dart';
import "package:intl/intl.dart";
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CalendarEditModel extends ChangeNotifier {
  CalendarEditModel(
      {this.id,
      this.notificationId,
      this.titleText,
      this.timeText,
      this.memoText,
      this.isOn,
      this.notificationTime}) {
    titleTextController.text = titleText.toString();
    memoTextController.text = memoText.toString();
    _time = formatter.parse(timeText!);
    existingNotificationTime = notificationTime;
    existingTime = formatter.parse(timeText!);
  }
  final titleTextController = TextEditingController();
  final memoTextController = TextEditingController();
  final formatter = DateFormat('yyyy/MM/dd(E) HH:mm', "ja");
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int? id;
  String? titleText;
  String? memoText;
  late DateTime existingTime;
  late DateTime _time;
  late String? existingNotificationTime;
  bool? isOn;
  String? notificationTime;
  String? timeText;
  List<int>? notificationIdList;
  int? notificationId;

  void setTitleText(String titleText) {
    this.titleText = titleText;
    notifyListeners();
  }

  void setMemoText(String memoText) {
    this.memoText = memoText;
    notifyListeners();
  }

  void onChecked(bool value) {
    isOn = value;
    notifyListeners();
  }

  Future<void> _getNotificationId() async {
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
    timeText = formatter.format(_time);
    notifyListeners();
  }

  //通知時間を設定する。
  void settingNotification(String notificationTimebars) {
    notificationTime = "$notificationTimebars前";
    notifyListeners();
  }

  void _selectionNotificationTime(String notificationTime) {
    switch (notificationTime) {
      case '１５分前':
        _time = _time.add(const Duration(minutes: 1) * -1);
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

//通知機能
  Future _setNotify({int? id, DateTime? time}) async {
    final scheduleTime = tz.TZDateTime(
        tz.local, time!.year, time.month, time.day, time.hour, time.minute);
    final now = DateTime.now();
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
          ' ${notificationTime!.replaceAll("前", "")}後に以下の予定があります.$titleText',
          scheduleTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  //既存の通知設定をキャンセルする
  Future<void> _cancelNotifiacation(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  //更新処理
  Future update() async {
    titleText = titleTextController.text;
    memoText = memoTextController.text;

    if (titleText == '') {
      throw ('タイトルが入力されていません');
    }
    if (timeText == '') {
      throw ('日時が設定されていません');
    }

    if (isOn == true) {
      await _cancelNotifiacation(notificationId!);
      _selectionNotificationTime(notificationTime!);
      await _getNotificationId();
      await _setNotify(id: notificationId, time: _time);
    } else {
      await _cancelNotifiacation(notificationId!);
    }
    final calendarUpdate = Event(
        id: id,
        notificationId: notificationId,
        titleText: titleText,
        timeText: timeText,
        memoText: memoText,
        isOn: isOn! ? 1 : 0,
        notificationTime: isOn! ? notificationTime : "");
    await _update(calendarUpdate);
  }

  Future _update(Event event) async {
    final db = await DBProvider.db.database;
    await db.update('event', event.toMap(),
        where: "id = ?",
        whereArgs: [event.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
