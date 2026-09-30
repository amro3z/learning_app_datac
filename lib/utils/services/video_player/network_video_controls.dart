import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:training/ui/core/base.dart';

class NetworkVideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final Future<void> Function() onToggle;
  final Future<void> Function() onFullscreen;

  const NetworkVideoControls({
    super.key,
    required this.controller,
    required this.onToggle,
    required this.onFullscreen,
  });

  String _format(Duration value) {
    final seconds = value.inSeconds.clamp(0, 359999);
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: value.aspectRatio == 0 ? 16 / 9 : value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: Center(
                child: value.isPlaying
                    ? const SizedBox.shrink()
                    : const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              ),
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VideoProgressIndicator(
                        controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          defaultText(
                            context: context,
                            text: _format(value.position),
                            size: 11,
                            bold: false,
                            maxLines: 1,
                          ),
                          defaultText(
                            context: context,
                            text: _format(value.duration),
                            size: 11,
                            bold: false,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFullscreen,
                  icon: const Icon(Icons.fullscreen, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
