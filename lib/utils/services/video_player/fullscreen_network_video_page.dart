import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:training/utils/services/video_player/network_video_controls.dart';

class FullScreenNetworkVideoPage extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenNetworkVideoPage({super.key, required this.controller});

  @override
  State<FullScreenNetworkVideoPage> createState() =>
      _FullScreenNetworkVideoPageState();
}

class _FullScreenNetworkVideoPageState
    extends State<FullScreenNetworkVideoPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _togglePlayback() async {
    if (widget.controller.value.isPlaying) {
      await widget.controller.pause();
    } else {
      await widget.controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _close() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: NetworkVideoControls(
            controller: widget.controller,
            onToggle: _togglePlayback,
            onFullscreen: _close,
          ),
        ),
      ),
    );
  }
}
