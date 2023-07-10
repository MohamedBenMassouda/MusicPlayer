import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:music_app/pages/home_page.dart';

void main() async {
  var audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelName: 'Music App',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  Future<void> play() async {

  }

  Future<void> pause() async {

  }

  Future<void> stop() async {

  }

  Future<void> seek(Duration position) async {

  }
}