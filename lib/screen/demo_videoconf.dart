import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sdk_demo/screen/demo_home.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';

class VideoConferenceDemo extends StatefulWidget {
  const VideoConferenceDemo({super.key});

  @override
  State<VideoConferenceDemo> createState() => _VideoConferenceDemoState();
}

class _VideoConferenceDemoState extends State<VideoConferenceDemo> {
  Omnitalk omnitalk = Omnitalk.getInstance();
  String sessionId = '';
  String _roomSubject = ' ';
  String? selectedRoomId = ' ';
  var roomId;
  List<dynamic> _roomList = [];
  List publishList = [];

  RTCVideoRenderer localVideo = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo1 = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo2 = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo3 = RTCVideoRenderer();
  List<RTCVideoRenderer> renderers = [];
  int count = 1;
  List<bool> flags = [false, false, false];

  var _futureRoomList;
  Timer? _debounce;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode focusnode = FocusNode();
  bool isDropdownSelected = false;
  bool isBroadcastingStarted = false;
  bool _isInputVisible = true;
  bool toggle = true;
  List<bool> isVideoPlayingList = [];
  bool hasLeft = true;

  _VideoConferenceDemoState() {
    omnitalk.on('event', (dynamic event) async {
      switch (event["cmd"]) {
        case "BROADCASTING_EVENT":
        print(event);
          await omnitalk.subscribe(
              publisherSession: event['session'],
              remoteRenderer: renderers[count]);
          setState(() {
            count++;
          });
          break;
        case "CONNECTED_EVENT":
          print('Audio connected');
          break;
        case "LEAVE_EVENT":
          print('Session closed ${event["session"]}');
          break;
      }
    });
    renderers = [localVideo, remoteVideo1, remoteVideo2, remoteVideo3];
  }

  _onCreateSession() async {
    await omnitalk.getPermission();
    var session = await omnitalk.createSession();

    sessionId = session["session"];

    var result = await omnitalk.roomList();
    _roomList = result['list'];
    print(_roomList);
    setState(() {
      _roomList;
    });
    return _roomList;
  }

  _onJoinRoom() async {
    await omnitalk.joinRoom(roomId: selectedRoomId!);
  }

  _onCreateJoinRoom() async {
    var roomObj = await omnitalk.createRoom(
        roomType: RoomType.videoroom, subject: _roomSubject);

    roomId = roomObj?["room_id"];
    await omnitalk.joinRoom(roomId: roomId);
    isDropdownSelected = true;
  }

  _onLeave() async {
    await omnitalk.leave();
    await localVideo.dispose();
  }

  _onPubSub() async {
    await omnitalk.publish(localRenderer: localVideo);
    var result = await omnitalk.publishList();
    publishList = result["list"];

    for (int i = 0; i < publishList.length; i++) {
      var session = publishList[i]['session'];
      await omnitalk.subscribe(
          publisherSession: session, remoteRenderer: renderers[i + 1]);
      count++;
    }
    setState(() {
      renderers;
    });
    _isInputVisible = false;
  }

  _onCreateNewRoom() async {
    setState(() {
      isDropdownSelected = true;
      _roomSubject = _inputController.text;
    });
    await _onCreateJoinRoom();
    focusnode.unfocus(disposition: UnfocusDisposition.previouslyFocusedChild);
  }

  void _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
  }

  _onPuasePressed() async {
    print(sessionId);
    await omnitalk.setMute(track: TrackType.audio);
    await omnitalk.setMute(track: TrackType.video);
    setState(() {
      toggle = !toggle;
    });
  }

  @override
  void initState() {
    super.initState();
    _futureRoomList = _onCreateSession();
  }

  @override
  Widget build(BuildContext context) {
    final appbarHeight = AppBar().preferredSize.height;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - appbarHeight;

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Video Conference",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                hasLeft ? _onLeave() : null;
                hasLeft = false;
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Leave',
            )
          ],
          backgroundColor: Colors.white,
          foregroundColor: Colors.orange[900],
        ),
        body: FutureBuilder(
          future: _futureRoomList,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final dynamic data = snapshot.data ?? [];
              List<dynamic> roomList = data is List ? data : [];
              return Container(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    Visibility(
                      visible: _isInputVisible,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 17,
                          ),
                          onDropDown(roomList),
                          const SizedBox(
                            height: 20,
                          ),
                          onSubjectInput(),
                          const SizedBox(
                            height: 20,
                          ),
                          onCreateRoom(),
                          const SizedBox(height: 24),
                          onStartConference(),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    onVideo(screenWidth, availableHeight)
                  ],
                ),
              );
            }
          },
        ));
  }

  Expanded onVideo(double screenWidth, double availableHeight) {
    return Expanded(
      child: GridView.count(
        // shrinkWrap: true,
        crossAxisCount: 2,
        children: _buildVideoItems(4),
        childAspectRatio: (0.5 * screenWidth) / (0.5 * availableHeight),
      ),
    );
  }

  _buildVideoItems(int count) {
    List<Widget> items = [];
    isVideoPlayingList = List<bool>.filled(count, false);
    // print(toggle);

    for (int i = 0; i < count; i++) {
      print(renderers[i] != null);
      items.add(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // isVideoPlayingList[0] = true;
            return RTCVideoView(
              renderers[i],
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              mirror: i == 0 ? true : false,
            );
          },
        ),
      );
    }
    return items;
  }

  ElevatedButton onStartConference() {
    return ElevatedButton(
      onPressed: () {
        _onPubSub();

        setState(() {
          isBroadcastingStarted = true;
          isDropdownSelected = true;
        });
      },
      style: ButtonStyle(
        backgroundColor: isBroadcastingStarted
            ? MaterialStateProperty.all<Color>(Colors.grey)
            : MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
        minimumSize: MaterialStateProperty.all<Size>(const Size(150, 50)),
      ),
      child: const Text('Start Conference'),
    );
  }

  ElevatedButton onCreateRoom() {
    return ElevatedButton(
      onPressed: isDropdownSelected
          ? null
          : () {
              _onCreateNewRoom();
            },
      style: ButtonStyle(
        backgroundColor: isDropdownSelected
            ? MaterialStateProperty.all<Color>(Colors.grey)
            : MaterialStateProperty.all<Color>(Colors.deepOrangeAccent),
        minimumSize: MaterialStateProperty.all<Size>(const Size(150, 50)),
      ),
      child: const Text('Create Room'),
    );
  }

  SizedBox onSubjectInput() {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _inputController,
        focusNode: focusnode,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
            prefixIcon: Icon(Icons.recommend_rounded),
            hintText: 'Enter Room Subject',
            contentPadding: EdgeInsets.symmetric(vertical: 16)),
        onChanged: (value) {
          _onInputChanged();
        },
        enabled: !isDropdownSelected,
      ),
    );
  }

  DropdownButton<Object> onDropDown(List<dynamic> roomList) {
    return DropdownButton(
      hint: const Text('Select a room'),
      value: roomList.any((item) => item["room_id"] == selectedRoomId)
          ? selectedRoomId
          : null,
      items: roomList.isNotEmpty
          ? roomList.map((item) {
              return DropdownMenuItem(
                value: item["room_id"],
                child: Text(item["room_id"]),
              );
            }).toList()
          : null,
      onChanged: (value) {
        setState(() {
          selectedRoomId = value as String;
        });
        _onJoinRoom();
        isDropdownSelected = true;
        roomId = selectedRoomId;
      },
      iconEnabledColor: Colors.orange,
      iconDisabledColor: Colors.grey,
    );
  }
}
