import 'dart:async';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();


    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    context.read<LessonsCubit>().getLessons();

    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveProgress();
    });
  }

  void _restorePosition() {

    if (_positionRestored) {
      return;
    }

    final lessonsState = context.read<LessonsCubit>().state;
    final userId = context.read<UserCubit>().userId;


    if (lessonsState is! LessonsLoaded || userId == null) {
      return;
    }

    final progress = lessonsState.progress.firstWhere(
      (p) =>
          p.lesson == widget.lessonId &&
          p.courseId == widget.courseId &&
          p.userId == userId,
      orElse: () {
        return LessonProgressModel.empty();
      },
    );

    if (progress.watchedSeconds > 0) {
      _controller.seekTo(Duration(seconds: progress.watchedSeconds));
    } else {
    }

    _positionRestored = true;
  }

  void _saveProgress() {
    if (!_controller.value.isReady) {
      return;
    }

    final position = _controller.value.position.inSeconds;

    if (position <= 0) return;

    final userId = context.read<UserCubit>().userId;
    if (userId == null) {
      return;
    }

    context.read<LessonsCubit>().updateLessonProgress(
      lessonId: widget.lessonId,
      courseId: widget.courseId,
      userId: userId,
      watchedSeconds: position,
    );
  }

  @override
  void dispose() {

    _progressTimer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressColors: const ProgressBarColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
      ),
      progressIndicatorColor: Colors.blueAccent,
      
      onReady: () {
        Future.delayed(const Duration(milliseconds: 500), () {
          _restorePosition();
        });
      },
    );
  }
}
