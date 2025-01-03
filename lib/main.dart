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

class MyApp extends StatefulWidget {
  MyApp({super.key, required this.isSet});

  late bool isSet;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Background Service Example')),
        body: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Bell Duration in minute(s)',
              ),
            ),
            widget.isSet
                ? ElevatedButton(
                    onPressed: () {
                      // Stop the background service
                      widget.isSet = false;
                      storeData(false);
                      _controller.text = '0';
                      FlutterBackgroundService().invoke('stopService');
                      setState(() {});
                    },
                    child: Text('Stop Service'))
                : ElevatedButton(
                    onPressed: () {
                      // Stop the background service
                      widget.isSet = true;
                      storeData(true);
                      storeTime();
                      FlutterBackgroundService().startService();
                      setState(() {});
                    },
                    child: Text('Start Service')),
            widget.isSet
                ? const Center(
                    child: Text('Service is running in the background'))
                : const Center(
                    child: Text('Service is not running in the background')),
          ],
        ),
      ),
    );
  }

  void storeData(bool isSet) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('bell', isSet);
  }

  void storeTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('time', int.tryParse(_controller.text) ?? 0);
  }
}

@pragma('vm:entry-point')
Future<int> getTime() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getInt('time') ?? 0;
}

@pragma('vm:entry-point')
Future<bool> getData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getBool('bell') ?? false;
}
