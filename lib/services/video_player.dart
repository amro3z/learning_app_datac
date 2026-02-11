import 'dart:async';
import 'dart:developer';
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

    log("🟢 initState called");

    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl)!;

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    context.read<LessonsCubit>().getLessons();

    _progressTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      log("⏱ Timer triggered");
      _saveProgress();
    });
  }


  void _restorePosition() {
    log("🔵 restorePosition called");

    if (_positionRestored) {
      log("⚠️ Position already restored — skipping");
      return;
    }

    final lessonsState = context.read<LessonsCubit>().state;
    final userId = context.read<UserCubit>().userId;

    log("📦 Lessons state type: ${lessonsState.runtimeType}");
    log("👤 UserId: $userId");

    if (lessonsState is! LessonsLoaded || userId == null) {
      log("❌ Lessons not loaded or user null");
      return;
    }

    final progress = lessonsState.progress.firstWhere(
      (p) =>
          p.lesson == widget.lessonId &&
          p.courseId == widget.courseId &&
          p.userId == userId,
      orElse: () {
        log("❌ No progress found for this lesson");
        return LessonProgressModel.empty();
      },
    );

    log("📍 Server watchedSeconds = ${progress.watchedSeconds}");

    if (progress.watchedSeconds > 0) {
      log("➡️ Seeking to ${progress.watchedSeconds}");
      _controller.seekTo(Duration(seconds: progress.watchedSeconds));
    } else {
      log("ℹ️ watchedSeconds = 0, starting from beginning");
    }

    _positionRestored = true;
  }

  void _saveProgress() {
    if (!_controller.value.isReady) {
      log("❌ Controller not ready");
      return;
    }

    final position = _controller.value.position.inSeconds;

    log("🎥 Current player position = $position");

    if (position <= 0) return;

    final userId = context.read<UserCubit>().userId;
    if (userId == null) {
      log("❌ userId null while saving");
      return;
    }

    final status = position >= widget.lessonDurationInSeconds
        ? "completed"
        : "present";

    log("📤 Sending update → seconds: $position , status: $status");

    context.read<LessonsCubit>().updateLessonProgress(
      lessonId: widget.lessonId,
      courseId: widget.courseId,
      userId: userId,
      watchedSeconds: position,
      status: status,
    );
  }

  @override
  void dispose() {
    log("🔴 dispose called");

    _progressTimer?.cancel();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("🟡 build called");

    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      onReady: () {
        log("🟢 Player ready");
        Future.delayed(const Duration(milliseconds: 500), () {
          _restorePosition();
        });
      },
    );
  }
}
