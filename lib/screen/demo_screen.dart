import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({super.key});

  @override
  State<FlutterDemo> createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  Omnitalk omnitalk = Omnitalk.getInstance();
  Map<String, bool> flag = {};
  // String user_id = 'tester_ellie15';
  String roomSubject = 'test room14';

  String sessionId = '';
  String roomId = '';
  Map<String, dynamic>? roomObj;
  Map<String, dynamic>? joinResult;
  Map<String, dynamic>? publishResult;
  late int publishIdx;

  RTCVideoRenderer localVideo = RTCVideoRenderer();

  RTCVideoRenderer remoteVideo = RTCVideoRenderer();

  List partiList = [];

  final TextEditingController _inputController = TextEditingController();
  String? publisherSession;

  // var session;

  bool displayOn = false;
  bool remoteOn = false;
  bool toggle = true;
  List subSessions = [];
  bool isCameraSwitched = false;
  bool isAudioBack = false;
  bool isEarpiece = false;

  _FlutterDemoState() {
    print('flutter start');

    omnitalk.on('event', (dynamic event) async {
      var msg = event;
      print(msg);
      switch (msg["cmd"]) {
        case "BROADCASTING_EVENT":
          setState(() {
            publisherSession = msg['session'];
          });
          print('publisherSession : $publisherSession');
          break;
        case "CONNECTED_EVENT":
          print('Audio Connected');
          break;
        case "LEAVE_EVENT":
          print('${msg['session']} has left');
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  dynamic _onCreateSession() async {
    await omnitalk.getPermission();
    var session = await omnitalk.createSession();
   print(session);
    // sessionId = session["session"];
    var roomlist = await omnitalk.roomList();
    var devices = await omnitalk.getDeviceList();
    print(devices);
  }

  dynamic _onCreateRoom() async {
    roomObj = await omnitalk.createRoom(roomType: RoomType.videoroom);
    roomId = roomObj?["room_id"];
  }

  dynamic _onJoinRoom() async {
    joinResult = await omnitalk.joinRoom(roomId: roomId);

    print(joinResult);
  }

  _onCreateJoinRoom() async {
    await _onCreateRoom();
    await _onJoinRoom();
  }

  dynamic _onPublish() async {
    var publishResult = await omnitalk.publish(localRenderer: localVideo);
    print('publish result session: ${publishResult['session']}');
    print(sessionId == publishResult['session']);
    setState(() {
      displayOn = true;
    });
  }

  dynamic _onSubscribe() async {
    if (publisherSession != null) {
      var subResult = await omnitalk.subscribe(
          publisherSession: publisherSession!, remoteRenderer: remoteVideo);
      setState(() {
        remoteOn = true;
      });
      print('subscribe result : $subResult');
    }
  }

  dynamic _onUnsubscribe() async {
    if (publisherSession != null) {
      var result =
          await omnitalk.unsubscribe(publisherSession: publisherSession!);
      print(result);
    } else {
      print('Invalid unsubscribe, $publisherSession');
    }
  }

  _onRoomList() async {
    var result = await omnitalk.roomList();
    print(result);
  }

  _onPublishList() async {
    var result = await omnitalk.publishList();
    print(result);
  }

  _onPartiList() async {
    var result = await omnitalk.partiList();
    print(result);
  }

  _onSetAudioMute() async {
   
    await omnitalk.setMute(track: TrackType.audio);
  }

  _onSetAudioUnmute() async {
    await omnitalk.setUnmute(track: TrackType.audio);
  }

  _onSetVideoMute() async {
    await omnitalk.setMute(track: TrackType.video);
  }

  _onSetVideoUnmute() async {
    await omnitalk.setUnmute(track: TrackType.video);
  }

  _onSwtichCamera() async {
    var devices = await omnitalk.getDeviceList();
    print(devices);

    isCameraSwitched
        ? await omnitalk.switchVideo(deviceId: '0')
        : await omnitalk.switchVideo(deviceId: '1');
    isCameraSwitched = !isCameraSwitched;
  }

  _onDestroy() async {
    await omnitalk.destroyRoom();
  }

  _onLeave() async {
    await omnitalk.leave();

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
          'BASIC API TEST',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.orange[900],
        elevation: 2,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: _onCreateSession,
                    child: const Text('create session')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onCreateRoom, child: const Text('create room')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onJoinRoom, child: const Text('join room')),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: _onPublish, child: const Text('publish')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSubscribe, child: const Text('subscribe')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onUnsubscribe,
                    child: const Text('unsubscribe')),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: _onRoomList, child: const Text('room list')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onPublishList,
                    child: const Text('publish list')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onPartiList, child: const Text('parti list'))
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: _onSetAudioMute,
                    child: const Text('Audio Mute')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetAudioUnmute,
                    child: const Text('Audio Unmute'))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: _onSetVideoMute,
                    child: const Text('Video Mute')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetVideoUnmute,
                    child: const Text('Video Unmute'))
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  color: Colors.grey,
                  height: 180,
                  width: 160,
                  child: displayOn ? RTCVideoView(localVideo) : null,
                ),
                const SizedBox(
                  width: 20,
                ),
                Container(
                    color: Colors.grey,
                    height: 180,
                    width: 160,
                    child: remoteOn ? RTCVideoView(remoteVideo) : null),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await _onDestroy();
              },
              child: const Text('Destroy Room'),
            ),
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
