import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sdk_demo/screen/demo_home.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';



class VideoCallDemo extends StatefulWidget {
  const VideoCallDemo({super.key});

  @override
  State<VideoCallDemo> createState() => _VideoCallDemoState();
}

class _VideoCallDemoState extends State<VideoCallDemo> {
  Omnitalk omnitalk = Omnitalk.getInstance();
  String userId = "omnitalk";
  String sessionId = '';
  String roomId = '';
  String roomType = '';
  String? callee;
  String? caller;
  String? callerSession;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode focusnode = FocusNode();
  Timer? _debounce;
  bool hasCalleeEntered = false;

  bool localOn = false;
  bool remoteOn = false;

  RTCVideoRenderer localVideo = RTCVideoRenderer();
  RTCVideoRenderer localAudio = RTCVideoRenderer();
  RTCVideoRenderer remoteVideo1 = RTCVideoRenderer();

  bool answerOn = false;
  bool videoToggle = true;
  bool audioToggle = true;
  bool isCameraSwitched = false;
  final List<dynamic> audioList = [];
  String selectedAudio = '';
  bool isDropdonwSelected = false;

  _VideoCallDemoState() {
    print('flutter start');
    omnitalk.on(
      'event',
      (dynamic event) async {
        print('RECEIVED EVENT : $event');
        switch (event["cmd"]) {
          case "RINGING_EVENT":
            await _onRingingVariables(event);
            break;
          case 'RINGBACK_EVENT':
            debugPrint('${event['caller']} is calling ${event['callee']}');
            setState(() {
              localOn = true;
            });
            break;
          case "CONNECTED_EVENT":
            await _onConnectVariables(event);
            break;
          case "BROADCASTING_EVENT":
            await _onBroadcastVariables(event);
            setState(() {
              remoteOn = true;
            });
            break;
        }
      },
    );
  }

  _onCreateSession() async {
    await omnitalk.getPermission();
    var sessionResult = await omnitalk.createSession(userId:  userId);
    sessionId = sessionResult["session"];
  }
  
  _onSessionList() async {
    var result = await omnitalk.sessionList();
    print('session list result : $result');
  }

   _onSetVariables(event) {
    roomId = event["room_id"];
    roomType = event["room_type"];
  }

  _onRingingVariables(event) {
    caller = event['caller'];
    debugPrint('ringing event from user_id : ${event['user_id']} ');
  }

  _onRingbackVariables(event) {
    debugPrint(event['callee']);
  }

  _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
    callee = _inputController.text;
    print(callee);
  }

  _onConnectVariables(event) {}

  _onBroadcastVariables(event) {
    caller = event['user_id'];
    callerSession = event['session'];
  }

  _onOfferCall() async {
    await omnitalk.offerCall(
       callType: CallType.videocall, callee: callee!,record: false, localRenderer: localVideo,  remoteRenderer: remoteVideo1);
    localOn = true;
    hasCalleeEntered = true;
  }

  _onAnswerCall() async {
    await omnitalk.answerCall(
       callType: CallType.videocall,caller: caller, localRenderer: localVideo, remoteRenderer: remoteVideo1);
    localOn = true;
    remoteOn = true;
  }

  _onRejectCall() async {
    await omnitalk.leave(session: callerSession);
  }

  _onHangUp() async {
    await omnitalk.leave();
  }

  _onSwtichCamera() async {
    // get device list first, and pass the video device id you select
    // it differs depending on the device
    // final devices = await omnitalk.getDeviceList();
    isCameraSwitched
        ? await omnitalk.switchVideo(deviceId: '1')
        : await omnitalk.switchVideo(deviceId: '0');
    isCameraSwitched = !isCameraSwitched;
  }

  _onSetVideoMute() async {
    await omnitalk.setMute(track:TrackType.video);
    videoToggle = !videoToggle;
  }

  _onSetVideoUnmute() async {
    await omnitalk.setUnmute(track:TrackType.video);
  }

  _onSetAudioMute() async {
    await omnitalk.setMute(track:TrackType.audio);
    audioToggle = !audioToggle;
  }

  _onSelectAudioDevice() async {
    final devices = await omnitalk.getDeviceList();
    final audioInput = devices.where((d) => d["audioinput"]);
    final audioOutput = devices.where((d) => d["audiooutput"]);
  }

  _onLeave() async {
    await omnitalk.leave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'VIDEO CALL',
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
                    child: const Text('Create Session')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSessionList,
                    child: const Text('Callee Candidate')),
                const SizedBox(
                  width: 10,
                ),
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
                // ElevatedButton(
                //     onPressed: _onInputCallee,
                //     child: const Text('')),

                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _inputController,
                    focusNode: focusnode,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.recommend_rounded),
                        hintText: 'Enter Callee',
                        contentPadding: EdgeInsets.symmetric(vertical: 16)),
                    onChanged: (value) {
                      _onInputChanged();
                    },
                    enabled: !hasCalleeEntered,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onOfferCall, child: const Text('Offer Call')),
                const SizedBox(
                  width: 10,
                ),
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
                    onPressed: _onAnswerCall, child: const Text('Answer Call')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onRejectCall, child: const Text('Reject Call')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onHangUp, child: const Text('Hang Up')),
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
                    onPressed: _onSwtichCamera,
                    child: const Text('Switch Camera')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetVideoMute,
                    child: const Text('Video Mute')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetVideoUnmute, child: const Text('Unmute')),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  color: Colors.grey,
                  height: 200,
                  width: 160,
                  child: localOn
                      ? RTCVideoView(
                          localVideo,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : null,
                ),
                const SizedBox(
                  width: 10,
                ),
                Container(
                    color: Colors.grey,
                    height: 200,
                    width: 160,
                    child: remoteOn
                        ? RTCVideoView(
                            remoteVideo1,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover,
                          )
                        : null),
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
                await _onLeave();
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => HomeScreen()));
              },
              
              child: const Text('채널 나가기'),
            ),
          ),
        ],
      ),
    );
  }
}
