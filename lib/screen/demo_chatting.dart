import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_sdk_demo/screen/demo_home.dart';
import 'package:omnitalk_sdk/omnitalk_sdk.dart';


class ChattingDemo extends StatefulWidget {
  const ChattingDemo({super.key});

  @override
  State<ChattingDemo> createState() => _ChattingDemoState();
}

class _ChattingDemoState extends State<ChattingDemo> {
  Omnitalk omnitalk = Omnitalk.getInstance();
  String userId = "videoTester";
  String sessionId = '';
  String roomId = '';
  String roomType = '';

  final TextEditingController _inputController = TextEditingController();
  // final TextEditingController _whisperController = TextEditingController(); //animator controller debugging error
  List<String> textArray = [];

  final FocusNode focusnode = FocusNode();
  final FocusNode whispernode = FocusNode();

  Timer? _debounce;
  bool hasTextEntered = false;

  bool answerOn = false;
  bool videoToggle = true;
  bool audioToggle = true;
  bool isCameraSwitched = false;
  final List<dynamic> audioList = [];
  String selectedAudio = '';
  bool isDropdonwSelected = false;
  String? message;
  String? target;

  _ChattingDemoState() {
    print('flutter start');
    omnitalk.on(
      'event',
      (dynamic event) async {
        print('RECEIVED EVENT : $event');

        switch (event["cmd"]) {
          case "MESSAGE_EVENT":
            await _onMessage(event);
            await _onSetTarget(event);
            break;
          case 'RINGBACK_EVENT':
            break;
          case "CONNECTED_EVENT":
            break;
          case "BROADCASTING_EVENT":
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

  dynamic _onCreateRoom() async {
    var roomObj = await omnitalk.createRoom(roomType: RoomType.audioroom);
    roomId = roomObj?["room_id"];
  }

  dynamic _onJoinRoom() async {
    if (roomId.isNotEmpty) {
      await omnitalk.joinRoom(roomId:roomId);
      return;
    } else {
      return 'Invalid room id';
    }
  }

  _onCandidate() async {
    var result = await omnitalk.getAvailableMessageUser();
    print('candidate result : $result');
  }

  _onSetAudioMute() async {
    await omnitalk.setMute(track: TrackType.audio);
  }

  _onSetAudioUnmute() async {
    await omnitalk.setUnmute(track: TrackType.audio);
  }

  _onMessageCandidate() async {
    var result = await omnitalk.getAvailableMessageUser();
    print(result);
  }

  _onSetTarget(event) {
    target = event['session'];
  }

  _onMessage(event) {
    if (event['message'] != null) {
      String newMessage = '';
      event['action'] == 'whisper'
          ? newMessage =
              ' Whisper from ${event['user_id']} : ${event['message']}'
          : null;
      event['action'] == 'send'
          ? newMessage = '${event['user_id']} : ${event['message']}'
          : null;
      textArray.add(newMessage);
      setState(() {
        textArray;
      });
    }
  }

  _onInputChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
    message = _inputController.text;
  }

  _onTargetChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
    // target = _whisperController.text;
  }

  _onSendMessage() async {
    if (message == null) {
      print('Nothing to send');
    } else {
      await omnitalk.sendMessage(action: MessageAction.send, message: message!);
      textArray.add('나 : $message');
      setState(
        () {
          textArray;
        },
      );
      _inputController.clear();
    }
  }

  _onSendWhisper() async {
    if (message == null) {
      print('Nothing to send');
    } else if (target == null) {
      print('No target to whisper');
    } else {
      await omnitalk.sendMessage(
          action: MessageAction.whisper, message: message!, target: target);
      textArray.add('Whisper to $target : $message');
      setState(() {
        textArray;
      });
      // _whisperController.clear();
    }
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
          'AUDIO & CHATTING',
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
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: _onMessageCandidate,
                    child: const Text('Msg Candidate')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetAudioMute,
                    child: const Text('Audio Mute')),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSetAudioUnmute, child: const Text('Unmute'))
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
                        prefixIcon: Icon(Icons.text_fields),
                        hintText: 'Enter Message',
                        contentPadding: EdgeInsets.symmetric(vertical: 16)),
                    onChanged: (value) {
                      _onInputChanged();
                    },
                    enabled: !hasTextEntered,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSendMessage, child: const Text('Send')),
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
                // SizedBox(
                //   width: 250,
                //   child: TextField(
                //     controller: _whisperController,
                //     focusNode: whispernode,
                //     textAlign: TextAlign.center,
                //     decoration: const InputDecoration(
                //         prefixIcon: Icon(Icons.telegram),
                //         hintText: 'whisper session',
                //         contentPadding: EdgeInsets.symmetric(vertical: 16)),
                //     onChanged: (value) {
                //       _onTargetChanged();
                //     },
                //     enabled: !hasTextEntered,
                //   ),
                // ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                    onPressed: _onSendWhisper, child: const Text('Whisper')),
                const SizedBox(
                  width: 10,
                ),
                // ElevatedButton(
                //     onPressed: _onRejectCall, child: const Text('Reject Call')),
                // const SizedBox(
                //   width: 10,
                // ),
                // ElevatedButton(
                //     onPressed: _onHangUp, child: const Text('Hang Up')),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: textArray.isEmpty ? 1 : textArray.length,
                itemBuilder: (BuildContext context, int index) {
                  if (textArray.isEmpty && index == 0) {
                    return const Text('No message');
                  } else if (textArray.isNotEmpty) {
                    return ListTile(
                      title: Text(textArray[index]),
                    );
                  }
                  return null;
                },
              ),
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
                
              },
              child: const Text('leave'),
            ),
          ),
        ],
      ),
    );
  }
}
