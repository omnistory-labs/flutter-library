import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key});

  @override
  State<FlutterDemo> createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  Omnitalk omnitalk;
  Map<String, bool> flag = {};
  String user_id = 'tester_ellie15';
  String roomSubject = 'test room14';

  String sessionId = '';
  String roomId = '';
  Map<String, dynamic>? roomObj;
  Map<String, dynamic>? joinResult;
  Map<String, dynamic>? publishResult;
  late int publishIdx;

  RTCVideoRenderer localVideo = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo1 = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo2 = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo3 = RTCVideoRenderer();
  List<RTCVideoRenderer> remoteVideos = [];
  int count = 0;

  List partiList = [];

  var session;

  bool displayOn = false;
  List<bool> flags = [false, false, false];
  bool toggle = true;
  List subSessions = [];
  bool isCameraSwitched = false;
  bool isAudioBack = false;
  bool isEarpiece = false;

  _FlutterDemoState()
      : omnitalk = Omnitalk("service id", "service key") {
    omnitalk.onmessage = (event) async {
      switch (event["cmd"]) {
        case "SESSION_EVENT":
          print('Session started ${event["session"]}');
          break;
        case "BROADCASTING_EVENT":
          // await omnitalk.subscribe(
          //     publish_idx: event["publish_idx"],
          //     remoteRenderer: remoteVideos[count]);
          await _onSubscribeEvent(event);

          setState(() {
            flags[count] = true;
            count++;
          });
          print("on broadcasting event");
          print(event["publish_idx"]);
          print(flags);
          break;
        case "ONAIR_EVENT":
          print(event["track_type"]);
          break;
        case "LEAVE_EVENT":
          print('Session closed ${event["session"]}');
          break;
      }
    };

    remoteVideos = [remoteVideo1, remoteVideo2, remoteVideo3];
  }

  @override
  void initState() {
    super.initState();
  }

  dynamic _onCreateSession() async {
    await omnitalk.getPermission();
    session = await omnitalk.createSession(user_id);
    sessionId = session["session"];
    var roomlist = await omnitalk.roomList();
    var devices = await omnitalk.getDeviceList();
    print(devices);
  }

  dynamic _onCreateRoom() async {
    roomObj = await omnitalk.createRoom(subject: roomSubject);
    roomId = roomObj?["room_id"];
  }

  dynamic _onJoinRoom() async {
    joinResult = await omnitalk.joinRoom(room_id: roomId);

    print(joinResult);

    var dataroomlist = await omnitalk.dataChannelRoomList();
    print('dataroom list: $dataroomlist');
    var datachannelpartilist = await omnitalk.dataChannelPartiList();
    print('datapartilist in join result : $datachannelpartilist');
  }

  _onCreateJoinRoom() async {
    await _onCreateRoom();
    await _onJoinRoom();
  }

  dynamic _onPublish() async {
    var publishResult = await omnitalk.publish(
        call_type: "videocall",
        record: false,
        localRenderer: localVideo,
        resolution: 'QVGA');

    publishIdx = publishResult["publish_idx"];
    setState(() {
      displayOn = true;
    });
  }

  dynamic _onSubscribe() async {
    var partiResult = await omnitalk.partiList(roomId);
    print("---------partilist----------");
    print(partiResult);

    for (var parti in partiResult) {
      int pubIdx = parti["publish_idx"];
      partiList.add(pubIdx);
    }

    for (int i = 0; i < partiList.length; i++) {
      int pubidx = partiList[i];

      var subresult = await omnitalk.subscribe(
          publish_idx: pubidx, remoteRenderer: remoteVideos[i]);
      print("---------subscribe--------");
      print(subresult);
      subSessions.add(subresult["new_session"]);
      setState(() {
        flags[i] = true;
        count++;
      });
      print("--sub session ---");
      print(subSessions);
    }
  }

  _onSubscribeEvent(event) async {
    var subresult = await omnitalk.subscribe(
        publish_idx: event["publish_idx"], remoteRenderer: remoteVideos[count]);
    subSessions.add(subresult["new_session"]);
    print("---------subsessions: $subSessions");
    print(subresult);
  }

  _onSetAudioMute() async {
    var result = await omnitalk.setAudioMute(toggle);

    print("------ audio mute-------");
    print(result);
    print(toggle);
    toggle = !toggle;
    // setState(() {
    //   toggle = !toggle;
    // });
  }

  _onSetVideoMute() async {
    var result = await omnitalk.setVideoMute(toggle);
    toggle = !toggle;
  }

  _onSwtichCamera() async {
    isCameraSwitched
        ? await omnitalk.setVideoDevice(sessionId, '1')
        : await omnitalk.setVideoDevice(sessionId, '0');
    isCameraSwitched = !isCameraSwitched;
  }

  _onSetAudioInput() async {
    isAudioBack
        ? await omnitalk.setAudioInput('2')
        : await omnitalk.setAudioInput('0');
    isAudioBack = !isAudioBack;
    print('isAudioBack : $isAudioBack');
  }

  _onSetAudioOutput() async {
    isEarpiece
        ? await omnitalk.setAudioOutput('speaker')
        : await omnitalk.setAudioOutput('earpiece');
    isEarpiece = !isEarpiece;
    print('is earpiece on : $isEarpiece');
  }

  dynamic _onLeave() async {
    await omnitalk.leave(sessionId);
    // for (int i = 0; i < subSessions.length; i++) {
    //   await omnitalk.leave(subSessions[i]);
    // }
    setState(() {
      displayOn = false;
    });
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
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
                onTap: () => {_onCreateJoinRoom()},
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('This is create & join room'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onPublish()},
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('This is publish request'),
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
                // onTap: () => {_onSubscribe()},
                onTap: () => {_onSwtichCamera()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('Tap to switch camera'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                // onTap: () => {_onSetVideoMute()},
                onTap: () => {_onSetAudioInput()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('Tap to test audio input'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                // onTap: () => {_onSwtichCamera()},
                // onTap: () => {_onSetAudioInput()},
                onTap: () => {_onSetAudioOutput()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('Tap to test audio output'),
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
                child: displayOn ? RTCVideoView(localVideo) : null,
              ),
              const SizedBox(
                width: 60,
              ),
              Container(
                  color: Colors.grey,
                  height: 200,
                  width: 160,
                  child: flags[0] ? RTCVideoView(remoteVideos[0]) : null),
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
                child: flags[1] ? RTCVideoView(remoteVideos[1]) : null,
              ),
              const SizedBox(
                width: 60,
              ),
              Container(
                  color: Colors.grey,
                  height: 200,
                  width: 160,
                  child: flags[2] ? RTCVideoView(remoteVideos[2]) : null),
            ],
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
