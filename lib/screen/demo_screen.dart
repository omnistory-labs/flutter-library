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
  String sessionId = '';
  String roomId = '';
  Map<String, dynamic>? roomObj;
  Map<String, dynamic>? joinResult;
  Map<String, dynamic>? publishResult;
  late int publishIdx;

  RTCVideoRenderer localVideo = RTCVideoRenderer();

  RTCVideoRenderer remoteVideo = RTCVideoRenderer();

  List partiList = [];
  String? selectedPublisher = ' ';

  String? publisherSession;
  List publishList = [];

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
    print('session : ');
    print(session);
    // sessionId = session["session"];
    var devices = await omnitalk.getDeviceList();
    print('device : ');
    print(devices);
  }

  dynamic _onCreateRoom() async {
    try {
      roomObj = await omnitalk.createRoom(roomType: RoomType.videoroom);
      setState(() {
        roomId = roomObj?["room_id"];
      });
    } catch (err) {
      throw Error();
    }
  }

  dynamic _onJoinRoom() async {
    try {
      await omnitalk.joinRoom(roomId: roomId);
    } catch (err) {
      throw Error();
    }
  }


  dynamic _onPublish() async {
    var publishResult = await omnitalk.publish(localRenderer: localVideo);
    print('publish result session: ${publishResult['session']}');
    print('is sessionId == ${publishResult['session']}');
    print(sessionId == publishResult['session']);
    setState(() {
      displayOn = true;
    });
  }

  dynamic _onSubscribe() async {
    try {
      if (selectedPublisher != null) {
        var subResult = await omnitalk.subscribe(
            publisherSession: selectedPublisher!, remoteRenderer: remoteVideo);
        setState(() {
          remoteOn = true;
        });
        print('subscribe result : $subResult');
      }
    } catch (err) {
      throw Error();
    }
  }

  dynamic _onUnsubscribe() async {
    try {
        if (selectedPublisher != null) {
      var result =
          await omnitalk.unsubscribe(publisherSession: selectedPublisher!);
      print(result);
    } else {
      print('Invalid unsubscribe, ${selectedPublisher}');
    }
    } catch (err) {
        throw Error();
    }
  }

  _onRoomList() async {
    var result = await omnitalk.roomList();
    print(result);
  }

  _onPublishList() async {
    try {
      var result = await omnitalk.publishList();
      setState(() {
        publishList = result['list'];
      });
    } catch (err) {
      throw Error();
    }
  }

  DropdownButton<Object> onDropDown(List<dynamic> publishList) {
    return DropdownButton(
      hint: const Text('Select'),
      value: publishList.any((item) => item["session"] == selectedPublisher)
          ? selectedPublisher
          : null,
      items: publishList.isNotEmpty
          ? publishList.map((item) {
              return DropdownMenuItem(
                value: item["session"],
                child: Text(item["session"]),
              );
            }).toList()
          : null,
      onChanged: (value) {
        setState(() {
          selectedPublisher = value as String;
        });
      },
      iconEnabledColor: Colors.orange,
      iconDisabledColor: Colors.grey,
    );
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
      _freeResources();
    });
  }

  _freeResources() {
    flag = {};
    roomId = '';
    roomObj = {};
    joinResult = {};
    publishResult = {};
    publishIdx = 0;
    localVideo = RTCVideoRenderer();
    remoteVideo = RTCVideoRenderer();
    partiList = [];
    selectedPublisher = ' ';
    publisherSession = '';
    publishList = [];
    displayOn = false;
    remoteOn = false;
    toggle = true;
    subSessions = [];
    isCameraSwitched = false;
    isAudioBack = false;
    isEarpiece = false;
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
        body: SingleChildScrollView(
          child: Column(
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
                        onPressed: _onCreateRoom,
                        child: const Text('create room')),
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
                child: Text('roomId : $roomId'),
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
                        // onPressed: _onSubscribe, child: const Text('subscribe')
                        onPressed: _onPublishList,
                        child: const Text('publish list')),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [onDropDown(publishList)],
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
                        onPressed: _onSubscribe,
                        child: const Text('Subscribe')),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                        onPressed: _onUnsubscribe,
                        child: const Text('Unsubscribe')),
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
                        child: const Text('Audio Unmute')),
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
                      child: displayOn ? RTCVideoView(localVideo, objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ) : null,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Container(
                        color: Colors.grey,
                        height: 180,
                        width: 160,
                        child: remoteOn ? RTCVideoView(remoteVideo, objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              ) : null),
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
                  child: const Text('leave'),
                ),
              ),
            ],
          ),
        ));
  }
}
