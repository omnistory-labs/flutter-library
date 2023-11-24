import 'package:flutter/material.dart';
import 'package:flutter_sdk_demo/screen/demo_audiocall.dart';
import 'package:flutter_sdk_demo/screen/demo_chatting.dart';
import 'package:flutter_sdk_demo/screen/demo_screen.dart';
import 'package:flutter_sdk_demo/screen/demo_videocall.dart';
import 'package:flutter_sdk_demo/screen/demo_videoconf.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key) {
    Omnitalk.sdkInit(
        serviceId: 'FM51-HITX-IBPG-QN7H', serviceKey: 'FWIWblAEXpbIims');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FlutterDemo()));
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 255, 123, 0))),
              child: const Text(
                'Basic Function Test',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AudioCallDemo()));
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 255, 123, 0))),
              child: const Text(
                'Audio Call',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VideoCallDemo()));
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 255, 123, 0))),
              child: const Text(
                'Video Call',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const VideoConferenceDemo()));
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 255, 123, 0))),
              child: const Text(
                'Video Conference',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChattingDemo()));
              },
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 255, 123, 0))),
              child: const Text(
                'Audio & Chatting Room',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
