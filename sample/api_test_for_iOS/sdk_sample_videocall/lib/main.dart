import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:sdk_sample_videocall/screen/sample_audiocall.dart';
import 'package:sdk_sample_videocall/screen/sample_videocall.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final time = DateFormat('yyyy-MM-dd HH:mm:ss').format(record.time);
    print('${record.level.name} : $time : ${record.message}');
  });
  runApp(const MaterialApp(
    home: VideoCallDemo(),
    // home: VideoConferenceDemo(),
    // home: AudioCallDemo(),
  ));
}
