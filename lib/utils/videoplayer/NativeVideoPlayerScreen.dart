import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:video_player/video_player.dart';

class NativeVideoPlayerScreen extends StatefulWidget {
  final String videoPath;

  const NativeVideoPlayerScreen({super.key, required this.videoPath});

  @override
  _NativeVideoPlayerScreenState createState() =>
      _NativeVideoPlayerScreenState();
}

class _NativeVideoPlayerScreenState extends State<NativeVideoPlayerScreen> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
    _controller?.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController:
              _controller ??
              VideoPlayerController.networkUrl(Uri.parse(widget.videoPath)),
          autoPlay: true,
          looping: true,
          autoInitialize: true,
          allowFullScreen: false,
          aspectRatio: 16 / 9,
          showControlsOnInitialize: false,
        );
      });
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Video Player'),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child:
            _chewieController?.videoPlayerController.value.isInitialized ??
                    false
                ? Chewie(controller: _chewieController!)
                : Center(child: CircularProgressIndicator()),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _chewieController?.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
    _chewieController?.pause();
    _controller?.pause();
  }
}
