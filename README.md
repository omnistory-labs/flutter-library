# omnitalk_sdk
<p align="center">
  <img src="https://github.com/Luna-omni/readmdtest/assets/125844802/a910cb80-de3b-44d8-9f37-0ccd08b9dd19" width="500" height="100">
</p><br/>

# Omnitalk FLUTTER SDK

[옴니톡](omnitalk.io)은 webRTC 표준 기술을 이용하여 app에서 쉽고 간편하게 실시간 통신을 구현할 수 있는 SDK입니다.<br/>


<br/><br/>

## Feature Overview

| feature          | implemented | ios | android |
| ---------------- | :---------: | :-: | :-----: |
| Audio Call       |     ✔️      | ✔️  |   ✔️    |
| Video Call       |     ✔️      | ✔️  |   ✔️    |
| Sip Call         |     ✔️      |  ✔️ |   ✔️    |
| Chatting         |     ✔️      | ✔️  |   ✔️    |
| Audio Conference |     ✔️      | ✔️  |   ✔️    |
| Video Conference |     ✔️      | ✔️  |   ✔️    |
| AudioMute        |     ✔️      | ✔️  |   ✔️    |
| VideoMute        |     ✔️      | ✔️  |   ✔️    |
| Video Switch     |     ✔️      |  ✔️ |   ✔️    |


<br/>


## Pre-Requisite


- 서비스 아이디 & 옴니톡 서비스 키

  - [옴니톡 홈페이지](https://omnitalk.io) 를 방문하여 서비스 id와 서비스 key를 발급받아야 합니다.
  - 혹은 [이곳](https://omnitalk.io/demo/audio) 에서 1시간 동안 무료로 사용 가능한 테스트용 id, key를 발급받을 수 있습니다.

    <br/>
- 최소 지원 사양

    - Flutter >= 3.1.0
  - Dart >= 2.19
  - Android API 21
  - IOS>= 11
<br>


<br/>

## Demo 코드 실행 방법
Flutter app 실행을 위해 Android Studio와 Xcode가 미리 설치되어 있어야 합니다.

1. 소스코드 다운로드
2. service id, key 입력
    lib>screen>demo_home
    ```
    HomeScreen({Key? key}) : super(key: key) {
    Omnitalk.sdkInit(
        serviceId: 'Service ID', serviceKey: 'Service KEY');
    }
    ```

3. `flutter pub get`
4. 앱 실행
* Android Studio: `flutter run`
* Xcode : ios > Runner.xcworkspace 실행


## Demo 확인
|     screen     |    title |  주요 API |  주요 기능|
| ---------------- | :---------: | :-: | :-----: |
| demo_screen| Basic Function Test | createSession / createRoom / joinRoom/ publish/ subscribe/unsubscribe/ roomList/publishList/ partiList/ audio mute/ videomute| 세션 생성 및 룸 참여, 오디오 방송, 비디오 방송 및 구독 |
|  demo_audiocall      |   Audio Call /Sip Call     |  offerCall/ answerCall  |   1:1 음성 통화, Sip Call    |
|demo_videocall| Video Call | offerCall, answerCall, switchVideo | 1:1 영상 통화|
demo_chatting | Audio & Chatting | sendMessage | 음성회의 + 채팅|
|demo_videoconference|Video Conference|publish, subscribe|1:1/다자간 영상 회의|

* 구현 전 pub - sub 관계를 이해하면 좋습니다. 

  video subscribe를 하기 위해선 같은 room id의 룸에 참여해 자신의 방송을 publish 한 사람의 session이 필요합니다. (publishList()로 조회)
## Documentation

쉽고 자세한 [문서](https://docs.omnitalk.io/flutter)를 제공하고 있습니다.


## Issue

옴니톡을 사용하면서 발생하는 이슈나 궁금점은 [issue](https://github.com/omnistory-labs/omnitalk.flutter.sdk/issues) 페이지를 이용해 주세요.



