import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });

  await initializeTimeZone();
  await initializeService();
  final isSet = await getData();
  runApp(MyApp(
    isSet: isSet,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.isSet});

  final bool isSet;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Background Service Example')),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            isSet
                ? ElevatedButton(
                    onPressed: () {
                      // Stop the background service
                      storeData(false);
                      FlutterBackgroundService().invoke('stopService');
                    },
                    child: Text('Stop Service'))
                : ElevatedButton(
                    onPressed: () {
                      // Stop the background service
                      storeData(true);
                      FlutterBackgroundService().startService();
                    },
                    child: Text('Start Service')),
            isSet
                ? const Center(
                    child: Text('Service is running in the background'))
                : const Center(
                    child: Text('Service is not running in the background')),
          ],
        ),
      ),
    );
  }
}

void storeData(bool isSet) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setBool('bell', isSet);
}

Future<bool> getData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getBool('bell') ?? false;
}
