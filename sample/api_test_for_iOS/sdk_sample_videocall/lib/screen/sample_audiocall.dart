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
  String user_id = "ellie-audio";
  String SessionID = '';
  String roomId = '';
  String roomType = '';
  int publishIdx = 0;
  String callee = 'tester@omnistory.net';

  RTCVideoRenderer localAudio = RTCVideoRenderer();

  bool ringtoneOn = false;
  bool answerOn = false;
  bool audioToggle = true;
  bool isAudioBack = false;
  bool isBluetooth = false;

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
          break;
      }
    };
  }

  _onCreateSession() async {
    await omnitalk.getPermission();
    var session = await omnitalk.createSession(user_id);
    SessionID = session["session"];
    var device = await omnitalk.getDeviceList();
    print(device);
  }

  _onGetCallList() async {
    var result = await omnitalk.callList();
    print(result);
  }

  _onRingtone() {
    print('ringtone : $ringtoneOn');
    ringtoneOn
        ? FlutterRingtonePlayer.play(
            android: AndroidSounds.notification,
            ios: IosSounds.glass,
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

  _onSetAudioInput() async {
    isAudioBack
        ? await omnitalk.setAudioInput('2')
        : await omnitalk.setAudioInput('0');
    isAudioBack = !isAudioBack;
    print('isAudioBack : $isAudioBack');
  }

  _onSetAudioOutput() async {
    print('is bluetooth on : $isBluetooth');
    isBluetooth
        ? await omnitalk.setAudioOutput('bluetooth')
        : await omnitalk.setAudioOutput('speaker');
    isBluetooth = !isBluetooth;
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
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.all(12),
          //       child: FloatingActionButton(
          //         heroTag: "AudioCall",
          //         backgroundColor: Colors.green,
          //         onPressed: () => _onAnswerCall(),
          //         child: const Icon(
          //           Icons.call,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //     const SizedBox(
          //       width: 60,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.all(12),
          //       child: FloatingActionButton(
          //         heroTag: "RejectCall",
          //         backgroundColor: Colors.red,
          //         onPressed: () => _onHangUp(),
          //         child: const Icon(
          //           Icons.call_end,
          //           color: Colors.white,
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
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
