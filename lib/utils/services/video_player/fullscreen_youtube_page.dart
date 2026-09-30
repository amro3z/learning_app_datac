import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FullScreenYoutubePage extends StatefulWidget {
  final String videoId;
  final int startAt;
  final bool autoPlay;

  const FullScreenYoutubePage({
    super.key,
    required this.videoId,
    required this.startAt,
    required this.autoPlay,
  });

  @override
  State<FullScreenYoutubePage> createState() => _FullScreenYoutubePageState();
}

class _FullScreenYoutubePageState extends State<FullScreenYoutubePage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        startAt: widget.startAt,
        controlsVisibleAtStart: true,
      ),
    );
  }

  Future<void> _close() async {
    final second = _controller.value.position.inSeconds;

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      Navigator.pop(context, second);
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _close();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              bottomActions: [
                const CurrentPosition(),
                const ProgressBar(isExpanded: true),
                const RemainingDuration(),
                IconButton(
                  icon: const Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: _close,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
