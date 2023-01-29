import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../component/custom_video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: video == null ? _renderEmpty() : _renderVideo(),
    );
  }

  Widget _renderVideo() {
    return Center(
      child: CustomVideoPlayer(
        video: video!,
        onNewVideoPressed: _onNewVideoPressed,
      ),
    );
  }

  Widget _renderEmpty() {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: _boxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Logo(onTap: _onNewVideoPressed),
          SizedBox(height: 30),
          _AppName(),
        ],
      ),
    );
  }

  void _onNewVideoPressed() async {
    final video = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (video != null) {
      setState(() {
        this.video = video;
      });
    }
  }

  BoxDecoration _boxDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xff2a3a7c),
          Color(0xff000118),
        ],
      ),
    );
  }
}

class _AppName extends StatelessWidget {
  const _AppName({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
      fontWeight: FontWeight.w300,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'VIDEO',
          style: textStyle,
        ),
        Text(
          'PLAYER',
          style: textStyle.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  final VoidCallback onTap;

  const _Logo({
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset('asset/image/logo.png'),
    );
  }
}
