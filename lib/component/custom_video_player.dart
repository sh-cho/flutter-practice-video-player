import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final XFile video;
  final VoidCallback onNewVideoPressed;

  const CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController? videoController;
  late Duration currentPosition;
  bool showControls = false;

  @override
  void initState() {
    super.initState();

    initController();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// 새 비디오가 들어왔을 떄. 구분 ->
    if (oldWidget.video.path != widget.video.path) {
      initController();
    }
  }

  void initController() async {
    currentPosition = Duration();

    videoController = VideoPlayerController.file(
      File(widget.video.path),
    );

    await videoController!.initialize();

    videoController!.addListener(() {
      /// 재생됨에 따라 슬라이더 조정
      final currentPosition = videoController!.value.position;

      setState(() {
        this.currentPosition = currentPosition;
      });
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: videoController!.value.aspectRatio,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        child: Stack(
          children: [
            VideoPlayer(
              videoController!,
            ),
            if (showControls)
              _Controls(
                onForwardPressed: _onForwardPressed,
                onPlayPressed: _onPlayPressed,
                onReversePressed: _onReversePressed,
                isPlaying: videoController!.value.isPlaying,
              ),
            if (showControls)
              _NewVideo(
                onPressed: widget.onNewVideoPressed,
              ),
            _SliderBottom(
              currentPosition: currentPosition,
              maxPosition: videoController!.value.duration,
              onSliderChanged: _onSliderChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onSliderChanged(double value) {
    videoController!.seekTo(
      Duration(
        seconds: value.toInt(),
      ),
    );
  }

  // void _onNewVideoPressed() {}

  void _onPlayPressed() {
    /// 이미 실행중이면 중지
    /// 실행중이 아니면 실행

    setState(() {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    });
  }

  void _onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();
    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void _onForwardPressed() {
    final maxPosition = videoController!.value.duration;
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;
    if ((currentPosition + Duration(seconds: 3)) < maxPosition) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }
}

class _SliderBottom extends StatelessWidget {
  final Duration currentPosition;
  final Duration maxPosition;
  final ValueChanged<double> onSliderChanged;

  const _SliderBottom({
    required this.currentPosition,
    required this.maxPosition,
    required this.onSliderChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              '${currentPosition.inMinutes}:'
              '${(currentPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: maxPosition.inSeconds.toDouble(),
                value: currentPosition.inSeconds.toDouble(),
                onChanged: onSliderChanged,
              ),
            ),
            Text(
              '${maxPosition.inMinutes}:'
              '${(maxPosition.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewVideo extends StatelessWidget {
  final VoidCallback onPressed;

  const _NewVideo({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 10,
      top: 10,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(Icons.photo_camera_back),
        color: Colors.white,
        iconSize: 30,
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final VoidCallback onPlayPressed;
  final VoidCallback onReversePressed;
  final VoidCallback onForwardPressed;
  final bool isPlaying;

  const _Controls({
    required this.onPlayPressed,
    required this.onReversePressed,
    required this.onForwardPressed,
    required this.isPlaying,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _renderIconButton(
              onPressed: onReversePressed, iconData: Icons.rotate_left),
          _renderIconButton(
              onPressed: onPlayPressed,
              iconData: isPlaying ? Icons.pause : Icons.play_arrow),
          _renderIconButton(
              onPressed: onForwardPressed, iconData: Icons.rotate_right),
        ],
      ),
    );
  }

  Widget _renderIconButton({
    required VoidCallback onPressed,
    required IconData iconData,
  }) {
    return IconButton(
      onPressed: onPressed,
      iconSize: 30,
      icon: Icon(iconData),
      color: Colors.white,
    );
  }
}
