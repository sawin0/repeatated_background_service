import 'dart:async';
import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:just_audio/just_audio.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'main.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> initializeService() async {
  final isSet = await getData();
  if (!isSet) {
    FlutterBackgroundService().invoke('stopService');
    return;
  }
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onServiceStart,
      autoStart: isSet,
      isForegroundMode: true,
      autoStartOnBoot: true,
      initialNotificationTitle: 'Background Service',
      initialNotificationContent: 'Service is running',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: isSet,
      onForeground: onServiceStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onServiceStart(ServiceInstance service) async {
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration.speech(),
  );

  final int interval = await getTime();
  final Duration duration = Duration(minutes: interval);
  print(duration);

  // Listen for stop service signal
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(duration, (timer) async {
    // Play sound in the background
    await playSound();
    NotificationService.scheduleNotification(
        id: 1,
        title: 'Background Service',
        body: 'Service is running',
        scheduledDate: DateTime.now().add(duration));
  });
}

@pragma('vm:entry-point')
Future<void> playSound() async {
  final player = AudioPlayer();
  await player
      .setAsset('assets/notification.mp3'); // Ensure the file path is correct
  player.play();
}

@pragma('vm:entry-point')
Future<void> initializeTimeZone() async {
  tz.initializeTimeZones();
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
}
