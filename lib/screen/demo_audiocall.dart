import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sdk_demo/screen/demo_home.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';


class AudioCallDemo extends StatefulWidget {
  const AudioCallDemo({super.key});

  @override
  State<AudioCallDemo> createState() => _AudioCallDemoState();
}

class _AudioCallDemoState extends State<AudioCallDemo> {
  Omnitalk omnitalk = Omnitalk.getInstance();
  String userId = "audio-tester";
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

  _AudioCallDemoState() {
    print('flutter start');
    omnitalk.on(
      'event',
      (dynamic event) async {
        print('RECEIVED EVENT : $event');
        switch (event["cmd"]) {
          case "RINGING_EVENT":
            setState(() {
              caller = event['caller'];
            });
            debugPrint('ringing event from user_id : ${event['user_id']} ');
            break;
          case 'RINGBACK_EVENT':
            setState(() {
              callee = event['callee'];
            });
            debugPrint('${event['caller']} is calling ${event['callee']}');
            break;
          case "CONNECTED_EVENT":
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
    var sessionResult = await omnitalk.createSession(userId: userId);
    sessionId = sessionResult["session"];
  }

  _onParticipantList() async {
    var result = await omnitalk.partiList();
    print('parti list result : $result');
  }

  _onSessionList() async {
    var result = await omnitalk.sessionList();
    print('session list result : $result');
  }
  _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
    callee = _inputController.text;
    print(callee);
  }

  _onBroadcastVariables(event) {
    caller = event['user_id'];
    callerSession = event['session'];
  }

  _onOfferCall() async {
    await omnitalk.offerCall(
      callType:  CallType.audiocall, callee: callee!);
    localOn = true;
    hasCalleeEntered = true;
  }

  _onAnswerCall() async {
    await omnitalk.answerCall();
  }

  _onRejectCall() async {
    await omnitalk.leave(session: callerSession);
  }

  _onHangUp() async {
    await omnitalk.leave();
  }

  _onSetAudioMute() async {
    await omnitalk.setMute(track:TrackType.audio);
    audioToggle = !audioToggle;
  }

  _onSetAudioUnmute() async {
    await omnitalk.setUnmute(track: TrackType.audio);
  }

  _onSelectAudioDevice() async {
    final devices = await omnitalk.getDeviceList();
    final audioInput = devices.where((d) => d["audioinput"]);
    final audioOutput = devices.where((d) => d["audiooutput"]);
  }

  _onMakeSipNum() async {
    var result = await omnitalk.makeSipNum();
    print(result);
  }

  _onSipOfferCall() async {

    String SipCallee = '3000';  // 실제 걸고 싶은 전화 번호(일반전화/ 휴대폰 번호 등등)
    await omnitalk.offerCall(callType: CallType.sipcall, callee: SipCallee);
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
          'AUDIO CALL',
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

          Padding(padding: const EdgeInsets.all(8.0),
            child: Row(children: [Text('$caller is calling to you. Answer the call or reject it')],)),
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
                    onPressed: _onSetAudioMute,
                    child: const Text('Audio Mute')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetAudioUnmute,
                    child: const Text('Audio Unmute')),
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
                    onPressed: _onMakeSipNum,
                    child: const Text('Make Sip Num')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSipOfferCall,
                    child: const Text('Sip Offer Call')),
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
