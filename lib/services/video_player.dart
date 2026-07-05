import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:training/cubits/cubit/user_cubit.dart';
import 'package:training/cubits/cubit/lessons_cubit.dart';
import 'package:training/data/models/lesson_progress.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String youtubeUrl;
  final int lessonId;
  final int courseId;
  final int lessonDurationInSeconds;

  const YoutubePlayerWidget({
    super.key,
    required this.youtubeUrl,
    required this.lessonId,
    required this.courseId,
    required this.lessonDurationInSeconds,
  });

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  late YoutubePlayerController _controller;
  Timer? _progressTimer;

  bool _positionRestored = false;
  late final String _videoId;

  @override
  void initState() {
    super.initState();

    _videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? '';

    _controller = YoutubePlayerController(
      initialVideoId: _videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        controlsVisibleAtStart: true,
      ),
    );

    context.read<LessonsCubit>().getLessons();

    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveProgress();
    });
  }

  void _restorePosition() {
    if (_positionRestored) return;

    final lessonsState = context.read<LessonsCubit>().state;
    final userId = context.read<UserCubit>().userId;

    if (lessonsState is! LessonsLoaded || userId == null) {
      Future.delayed(const Duration(milliseconds: 500), _restorePosition);
      return;
    }

    final progress = lessonsState.progress.firstWhere(
      (p) =>
          p.lesson == widget.lessonId &&
          p.courseId == widget.courseId &&
          p.userId == userId,
      orElse: () => LessonProgressModel.empty(),
    );

    if (progress.watchedSeconds > 0) {
      _controller.seekTo(Duration(seconds: progress.watchedSeconds));
    }

    _positionRestored = true;
  }

  void _saveProgress() {
    if (!_controller.value.isReady) return;

    final position = _controller.value.position.inSeconds;
    if (position <= 0) return;

    final userId = context.read<UserCubit>().userId;
    if (userId == null) return;

    context.read<LessonsCubit>().updateLessonProgress(
      lessonId: widget.lessonId,
      courseId: widget.courseId,
      userId: userId,
      watchedSeconds: position,
    );
  }

  Future<void> _openFullScreen() async {
    final currentSecond = _controller.value.position.inSeconds;
    final wasPlaying = _controller.value.isPlaying;

    _controller.pause();

    final returnedSecond = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenYoutubePage(
          videoId: _videoId,
          startAt: currentSecond,
          autoPlay: wasPlaying,
        ),
      ),
    );

    if (returnedSecond != null) {
      _controller.seekTo(Duration(seconds: returnedSecond));
    }

    if (wasPlaying) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoId.isEmpty) {
      return const Center(child: Text("Invalid video URL"));
    }

    return Stack(
      children: [
        YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressColors: const ProgressBarColors(
            playedColor: Colors.blue,
            handleColor: Colors.blueAccent,
          ),
          progressIndicatorColor: Colors.blueAccent,
          onReady: _restorePosition,
          bottomActions: [
            const CurrentPosition(),
            const ProgressBar(isExpanded: true),
            const RemainingDuration(),
            IconButton(
              icon: const Icon(Icons.fullscreen, color: Colors.white),
              onPressed: _openFullScreen,
            ),
          ],
        ),
      ],
    );
  }
}

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
  late YoutubePlayerController _fullController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _fullController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        startAt: widget.startAt,
        controlsVisibleAtStart: true,
        disableDragSeek: false,
      ),
    );
  }

  Future<void> _closeFullScreen() async {
    final currentSecond = _fullController.value.position.inSeconds;

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      Navigator.pop(context, currentSecond);
    }
  }

  @override
  void dispose() {
    _fullController.dispose();

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
          _closeFullScreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: YoutubePlayer(
                  controller: _fullController,
                  showVideoProgressIndicator: true,
                  progressColors: const ProgressBarColors(
                    playedColor: Colors.blue,
                    handleColor: Colors.blueAccent,
                  ),
                  progressIndicatorColor: Colors.blueAccent,
                  bottomActions: [
                    const CurrentPosition(),
                    const ProgressBar(isExpanded: true),
                    const RemainingDuration(),
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                      ),
                      onPressed: _closeFullScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
