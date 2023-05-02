import 'package:flutter/material.dart';
import 'package:sample/screen/video_conference.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[100]!,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: const [
              // Text('this will be omnitalk logo'),
              Expanded(child: Logo()),
              Expanded(child: _Image()),
              Expanded(child: EntryButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange[800],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.orange[300]!,
                  blurRadius: 12.0,
                  spreadRadius: 5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 40.0,
                ),
                SizedBox(
                  width: 12.0,
                ),
                Text(
                  'OMNITALK LIVE',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return const Text('this will be Video display');
    // return Center(child: Image.asset('asset/img/home_img.png'));
    return Center();
  }
}

class EntryButton extends StatelessWidget {
  const EntryButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VideoConferenceDemo(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                minimumSize: const Size(double.infinity, 60)),
            child: const Text(
              'START',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            )),
      ],
    );
  }
}
