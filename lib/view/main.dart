import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:medicine/view/calendar.dart';
import 'package:medicine/view/list_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

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
  MobileAds.instance.initialize();
  runApp(MainApp());
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

void showAppTrackingTransparency() async {
  final TrackingStatus status =
      await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //トラッキングの許可ダイアログを開く
    showAppTrackingTransparency();
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
      locale: const Locale('ja', 'JP'),
    );
  }
}
