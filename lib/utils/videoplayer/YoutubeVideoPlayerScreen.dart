import 'package:flutter/material.dart';
import 'package:infixedu/utils/CustomScreenAppBarWidget.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const YoutubeVideoPlayerScreen({super.key, required this.videoId});

  @override
  _YoutubeVideoPlayerScreenState createState() =>
      _YoutubeVideoPlayerScreenState();
}

class _YoutubeVideoPlayerScreenState extends State<YoutubeVideoPlayerScreen> {
  YoutubePlayerController? _controller;
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        showLiveFullscreenButton: false,
      ),
    );
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomScreenAppBarWidget(title: 'Video Player'),
      body: SafeArea(
        child: Container(
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller:
                  _controller ??
                  YoutubePlayerController(
                    initialVideoId: widget.videoId,
                    flags: YoutubePlayerFlags(
                      autoPlay: true,
                      showLiveFullscreenButton: false,
                    ),
                  ),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.amber,
              progressColors: ProgressBarColors(
                playedColor: Colors.amber,
                handleColor: Colors.amberAccent,
              ),
              onReady: () {
                _controller?.addListener(() {});
              },
            ),
            builder: (context, player) => player,
          ),
        ),
      ),
    );
  }
}
