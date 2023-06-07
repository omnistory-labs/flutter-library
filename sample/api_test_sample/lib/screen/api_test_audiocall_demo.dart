import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class AudioCallDemo extends StatefulWidget {
  const AudioCallDemo({super.key});

  @override
  State<AudioCallDemo> createState() => _AudioCallDemoState();
}

class _AudioCallDemoState extends State<AudioCallDemo> {
  Omnitalk omnitalk;
  String user_id = "audio-tester";
  String SessionID = '';
  String roomId = '';
  String roomType = '';
  int publishIdx = 0;
  String callee = 'tester@omnistory.net';

  bool displayOn = false;

  RTCVideoRenderer localAudio = RTCVideoRenderer();

  bool ringtoneOn = false;
  bool answerOn = false;
  bool audioToggle = true;
  bool isAudioBack = false;
  bool isEarpiece = false;

  _AudioCallDemoState()
      : omnitalk = Omnitalk("service id를 넣으세요H", "service key를 넣으세요") {
    omnitalk.onmessage = (event) async {
      switch (event["cmd"]) {
        case "SESSION_EVENT":
          print('Session started ${event["session"]}');
          break;
        case "TRYING_EVENT":
          break;
        case "RINGING_EVENT":
          ringtoneOn = true;
          await _onRingtone();
          await _onSetVariables(event);
          break;
        case "CONNECTED_EVENT":
          ringtoneOn = false;
          await _onRingtone();
          break;
      }
    };
  }

  _onCreateSession() async {
    await omnitalk.getPermission();
    var session = await omnitalk.createSession(user_id);
    SessionID = session["session"];
  }

  _onGetCallList() async {
    var result = await omnitalk.callList();
    print(result);
  }

  _onRingtone() {
    ringtoneOn
        ? FlutterRingtonePlayer.play(
            android: AndroidSounds.ringtone,
            ios: IosSounds.alarm,
            looping: true, // Android only - API >= 28
            volume: 0.8, // Android only - API >= 28
            asAlarm: false, // Android only - all APIs
          )
        : FlutterRingtonePlayer.stop();
  }

  _onSetVariables(event) {
    roomId = event["room_id"];
    roomType = event["room_type"];
    publishIdx = event["publish_idx"];
  }

  _onOfferCall() async {
    await omnitalk.offerCall(
        room_type: "audiocall",
        callee: callee,
        record: false,
        localAudio: localAudio);
    ringtoneOn = true;
    await _onRingtone();
  }

  _onAnswerCall() async {
    await omnitalk.answerCall(
      room_id: roomId,
      room_type: roomType,
      publish_idx: publishIdx,
    );
  }

  _onRejectCall() async {
    await omnitalk.leave(SessionID);
  }

  _onHangUp() async {
    await omnitalk.leave(SessionID);
  }

  _onSetAudioMute() async {
    await omnitalk.setAudioMute(audioToggle);
    audioToggle = !audioToggle;
  }

  // Get device list first. This is just an example.
  _onSetAudioInput() async {
    isAudioBack
        ? await omnitalk.setAudioInput('2')
        : await omnitalk.setAudioInput('0');
    isAudioBack = !isAudioBack;
  }

// Get device list first. This is just an example.
  _onSetAudioOutput() async {
    isEarpiece
        ? await omnitalk.setAudioOutput('speaker')
        : await omnitalk.setAudioOutput('earpiece');
    isEarpiece = !isEarpiece;
  }

  _onLeave() async {
    await omnitalk.leave(SessionID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'OMNITALK LIVE',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange[900],
        elevation: 2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _onCreateSession(),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('This is create session'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onGetCallList()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('This is to get call list'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onOfferCall()},
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('This is offercall'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => {answerOn = true, _onAnswerCall()},
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('This is answercall'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onRejectCall()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('This is to reject call'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onHangUp()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('This is to hang up'),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _onSetAudioMute(),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('Tap to set audio mute'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onSetAudioInput()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('Tap to select audio input'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onSetAudioOutput()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('Tap to select autio output'),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await _onLeave();
              },
              child: const Text('채널 나가기'),
            ),
          ),
        ],
      ),
    );
  }
}
