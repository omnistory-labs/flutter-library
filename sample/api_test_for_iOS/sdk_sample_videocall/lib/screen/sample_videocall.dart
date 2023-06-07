import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class VideoCallDemo extends StatefulWidget {
  const VideoCallDemo({super.key});

  @override
  State<VideoCallDemo> createState() => _VideoCallDemoState();
}

class _VideoCallDemoState extends State<VideoCallDemo> {
  Omnitalk omnitalk;
  String user_id =
      "ellie-video"; //This is caller. If you pass empty string, Omnitalk server gives a random id.
  String SessionID = '';
  String roomId = '';
  String roomType = '';
  int publishIdx = 0;
  String callee = 'ellie@omnistory.net'; //This is callee.

  bool localOn = false;
  bool remoteOn = false;
  RTCVideoRenderer localVideo = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo = RTCVideoRenderer();
  bool ringtoneOn = false;
  bool answerOn = false;
  bool videoToggle = true;
  bool audioToggle = true;
  bool isCameraSwitched = false;

  _VideoCallDemoState()
      : omnitalk = Omnitalk("service id를 넣으세요H", "service key를 넣으세요") {
    omnitalk.onmessage = (event) async {
      switch (event["cmd"]) {
        case "SESSION_EVENT":
          print('Session started ${event["session"]}');
          break;
        case "TRYING_EVENT":
          setState(() {
            localOn = true;
          });
          break;
        case "RINGING_EVENT":
          ringtoneOn = true;
          await _onRingtone();
          await _onSetVariables(event);
          break;
        case "CONNECTED_EVENT":
          setState(() {
            localOn = true;
            remoteOn = true;
          });
          break;
        case "BROADCASTING_EVENT":
          await _onSetVariables(event);
          await omnitalk.subscribe(
              publish_idx: event["publish_idx"], remoteRenderer: remoteVideo);
          setState(() {
            remoteOn = true;
            localOn = true;
          });
          break;
      }
    };
  }

  _onCreateSession() async {
    await omnitalk.getPermission();
    var session = await omnitalk.createSession(user_id);
    SessionID = session["session"];
  }

  // To make a call, use user_id only in active state.
  // [{state: busy, user_id: NdeJFOeDBB}, {state: busy, user_id: 4408}, , {state: active, user_id: tester}]
  _onGetCallList() async {
    var result = await omnitalk.callList();
    print(result);
  }

  _onRingtone() {
    ringtoneOn
        ? FlutterRingtonePlayer.play(
            android: AndroidSounds.notification,
            ios: IosSounds.glass,
            looping: true, // Android only - API >= 28
            volume: 0.4, // Android only - API >= 28
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
        room_type: "videocall",
        callee: callee,
        record: false,
        localRenderer: localVideo);
    ringtoneOn = true;
    await _onRingtone();
  }

  _onAnswerCall() async {
    await omnitalk.answerCall(
        room_id: roomId,
        room_type: roomType,
        publish_idx: publishIdx,
        localRenderer: localVideo,
        remoteRenderer: remoteVideo);
  }

  _onRejectCall() async {
    await omnitalk.leave(SessionID);
    ringtoneOn = false;
  }

  _onHangUp() async {
    await omnitalk.leave(SessionID);
  }

  _onSwtichCamera() async {
    isCameraSwitched
        ? await omnitalk.setVideoDevice(SessionID, '1')
        : await omnitalk.setVideoDevice(SessionID, '0');
    isCameraSwitched = !isCameraSwitched;
  }

  _onSetVideoMute() async {
    await omnitalk.setVideoMute(videoToggle);
    videoToggle = !videoToggle;
  }

  _onSetAudioMute() async {
    await omnitalk.setAudioMute(audioToggle);
    audioToggle = !audioToggle;
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
                onTap: () => {
                  _onAnswerCall(),
                },
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
                onTap: () => _onSwtichCamera(),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('Tap to switch camera'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onSetVideoMute()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('Tap to set video mute (pause)'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onSetAudioMute()},
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('Tap to set audio mute'),
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
              Container(
                color: Colors.grey,
                height: 200,
                width: 160,
                child: localOn ? RTCVideoView(localVideo) : null,
              ),
              const SizedBox(
                width: 60,
              ),
              Container(
                  color: Colors.grey,
                  height: 200,
                  width: 160,
                  child: remoteOn ? RTCVideoView(remoteVideo) : null),
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
