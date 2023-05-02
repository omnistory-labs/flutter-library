import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key});

  @override
  State<FlutterDemo> createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  final Omnitalk omnitalk;
  Map<String, bool> flag = {};
  String user_id = 'tester_ellie14';
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

  _FlutterDemoState()
      // replace service id and service key with active ones
      // you can get a test key for 1 hour (visit omnitalk.io/demo/video)
      : omnitalk = Omnitalk("FM51-HITX-IBPG-QN7H", "FWIWblAEXpbIims") {
    omnitalk.onmessage = (event) async {
      switch (event["cmd"]) {
        case "SESSION_EVENT":
          print('Session started ${event["session"]}');
          break;
        case "BROADCASTING_EVENT":
          await omnitalk.subscribe(
              publish_idx: event["publish_idx"],
              remoteRenderer: remoteVideos[count]);
          setState(() {
            flags[count] = true;
            count++;
          });
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

    // var roomlist = await omnitalk.roomList();
    // var device = await omnitalk.getDeviceList();
  }

  dynamic _onCreateRoom() async {
    roomObj = await omnitalk.createRoom(subject: roomSubject);
    roomId = roomObj?["room_id"];
    print(roomId);
  }

  dynamic _onJoinRoom() async {
    joinResult = await omnitalk.joinRoom(room_id: roomId);
  }

  dynamic _onPublish() async {
    var publishJson = await omnitalk.publish(
        call_type: "videocall", record: false, localRenderer: localVideo);
    publishIdx = publishJson["publish_idx"];

    setState(() {
      displayOn = true;
    });
  }

  dynamic _onSubscribe() async {
    var partiResult = await omnitalk.partiList(roomId);

    for (var parti in partiResult) {
      int pubIdx = parti["publish_idx"];
      partiList.add(pubIdx);
    }

    for (int i = 0; i < partiList.length; i++) {
      int pubidx = partiList[i];

      await omnitalk.subscribe(
          publish_idx: pubidx, remoteRenderer: remoteVideos[i]);

      setState(() {
        flags[i] = true;
        count++;
      });
    }
  }

  dynamic _onLeave() async {
    await omnitalk.leave(sessionId);
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
                onTap: () => {_onCreateRoom()},
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('This is create room'),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onJoinRoom()},
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    color: Colors.grey,
                    height: 100,
                    width: 120,
                    child: const Text('Join room'),
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
                onTap: () => {_onPublish()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('This is publish request'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              GestureDetector(
                onTap: () => {_onSubscribe()},
                child: Container(
                  color: Colors.grey,
                  height: 100,
                  width: 120,
                  child: const Text('This is subscribe '),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                color: Colors.grey,
                height: 200,
                width: 170,
                child: displayOn
                    ? RTCVideoView(
                        localVideo,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : const Text('This is localVideoView'),
              ),
              Container(
                  color: Colors.grey,
                  height: 200,
                  width: 170,
                  child: flags[0]
                      ? RTCVideoView(
                          remoteVideos[0],
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const Text('This is remoteVideoView1')),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                color: Colors.grey,
                height: 200,
                width: 170,
                child: flags[1]
                    ? RTCVideoView(
                        remoteVideos[1],
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      )
                    : const Text('This is remoteVideoView2'),
              ),
              Container(
                  color: Colors.grey,
                  height: 200,
                  width: 170,
                  child: flags[2]
                      ? RTCVideoView(
                          remoteVideos[2],
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : const Text('This is remoteVideoView3')),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.deepOrange),
              ),
              onPressed: () async {
                await _onLeave();
              },
              child: const Text('LEAVE'),
            ),
          ),
        ],
      ),
    );
  }
}
