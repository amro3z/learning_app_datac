import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:training/data/models/lesson_progress.dart';
import 'package:training/ui/state/cubit/lessons_cubit.dart';
import 'package:training/ui/state/cubit/user_cubit.dart';
import 'package:training/utils/services/video_player/fullscreen_network_video_page.dart';
import 'package:training/utils/services/video_player/fullscreen_youtube_page.dart';
import 'package:training/utils/services/video_player/network_video_controls.dart';

class UniversalVideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final int lessonId;
  final int courseId;
  final int lessonDurationInSeconds;

  const UniversalVideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.lessonId,
    required this.courseId,
    required this.lessonDurationInSeconds,
  });

  @override
  State<UniversalVideoPlayerWidget> createState() =>
      _UniversalVideoPlayerWidgetState();
}

class _UniversalVideoPlayerWidgetState extends State<UniversalVideoPlayerWidget>
    with WidgetsBindingObserver {
  static const MethodChannel _secureChannel = MethodChannel('secure_screen');

  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _networkController;

  Timer? _progressTimer;

  String? _youtubeId;
  String? _error;

  bool _loading = true;
  bool _positionRestored = false;
  bool _isAppHidden = false;

  bool get _isYoutube => _youtubeId != null && _youtubeId!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _enableSecureMode();
    _initializePlayer();

    _progressTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _saveProgress(),
    );
  }

 Future<void> _initializePlayer() async {
    final url = widget.videoUrl.trim();

    log('========================================');
    log('[VIDEO_PLAYER] Received URL: $url');
    log('[VIDEO_PLAYER] Lesson ID: ${widget.lessonId}');
    log('[VIDEO_PLAYER] Course ID: ${widget.courseId}');
    log('========================================');

    if (url.isEmpty) {
      log('[VIDEO_PLAYER] ERROR: URL is empty');

      _setError('Invalid video URL');
      return;
    }

    try {
      _youtubeId = YoutubePlayer.convertUrlToId(url);

      if (_isYoutube) {
        log('[VIDEO_PLAYER] Type: YOUTUBE');
        log('[VIDEO_PLAYER] Original URL: $url');
        log('[VIDEO_PLAYER] YouTube ID: $_youtubeId');
        log('[VIDEO_PLAYER] Starting YouTube player...');

        _initializeYoutubePlayer();
        return;
      }

      log('[VIDEO_PLAYER] Type: NETWORK / DIRECT VIDEO');
      log('[VIDEO_PLAYER] URL to play: $url');

      await _initializeNetworkPlayer(url);
    } catch (e, stackTrace) {
      log('[VIDEO_PLAYER] Initialization failed: $e', stackTrace: stackTrace);

      _setError('This video link cannot be played');
    }
  }

  void _initializeYoutubePlayer() {
    _youtubeController = YoutubePlayerController(
      initialVideoId: _youtubeId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        disableDragSeek: false,
        controlsVisibleAtStart: true,
      ),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _error = null;
    });
  }

  Future<void> _initializeNetworkPlayer(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      _setError('Invalid video URL');
      return;
    }

    final path = uri.path.toLowerCase();

    VideoFormat? formatHint;

    if (path.endsWith('.m3u8')) {
      formatHint = VideoFormat.hls;
    }

    final controller = VideoPlayerController.networkUrl(
      uri,
      formatHint: formatHint,
      httpHeaders: const {'User-Agent': 'Mozilla/5.0', 'Accept': '*/*'},
    );

    _networkController = controller;

    try {
      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      controller.addListener(_onNetworkPlayerChanged);

      setState(() {
        _loading = false;
        _error = null;
      });

      log(
        '[VIDEO_PLAYER] READY '
        'duration=${controller.value.duration.inSeconds}s '
        'size=${controller.value.size}',
      );

      _restorePosition();
    } catch (e, stackTrace) {
      log('[VIDEO_PLAYER] Failed to open URL: $e', stackTrace: stackTrace);

      if (identical(_networkController, controller)) {
        _networkController = null;
      }

      await controller.dispose();

      _setError('This video link cannot be played directly');
    }
  }

  void _setError(String message) {
    if (!mounted) return;

    setState(() {
      _loading = false;
      _error = message;
    });
  }

  void _onNetworkPlayerChanged() {
    if (!mounted) return;

    final controller = _networkController;

    if (controller == null) return;

    if (controller.value.hasError) {
      log(
        '[VIDEO_PLAYER] Playback error: '
        '${controller.value.errorDescription}',
      );
    }

    setState(() {});
  }

  Future<void> _enableSecureMode() async {
    try {
      await _secureChannel.invokeMethod('enable');
      await _noScreenshot.screenshotOff();
    } catch (e) {
      log('[VIDEO_PLAYER] Enable secure mode error: $e');
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await _secureChannel.invokeMethod('disable');
      await _noScreenshot.screenshotOn();
    } catch (e) {
      log('[VIDEO_PLAYER] Disable secure mode error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pausePlayer();

        if (!_isAppHidden) {
          setState(() {
            _isAppHidden = true;
          });
        }

        break;

      case AppLifecycleState.resumed:
        if (_isAppHidden) {
          setState(() {
            _isAppHidden = false;
          });
        }

        _enableSecureMode();
        break;
    }
  }

  Future<void> _pausePlayer() async {
    if (_isYoutube) {
      _youtubeController?.pause();
      return;
    }

    final controller = _networkController;

    if (controller != null &&
        controller.value.isInitialized &&
        controller.value.isPlaying) {
      await controller.pause();
    }
  }

  void _restorePosition() {
    if (_positionRestored || !mounted) return;

    final lessonsState = context.read<LessonsCubit>().state;
    final userId = context.read<UserCubit>().userId;

    if (lessonsState is! LessonsLoaded || userId == null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_positionRestored) {
          _restorePosition();
        }
      });

      return;
    }

    final progress = lessonsState.progress.firstWhere(
      (progress) =>
          progress.lesson == widget.lessonId &&
          progress.courseId == widget.courseId &&
          progress.userId == userId,
      orElse: () => LessonProgressModel.empty(),
    );

    final watchedSeconds = progress.watchedSeconds;

    if (watchedSeconds > 0) {
      final position = Duration(seconds: watchedSeconds);

      if (_isYoutube) {
        _youtubeController?.seekTo(position);
      } else {
        final controller = _networkController;

        if (controller != null && controller.value.isInitialized) {
          final duration = controller.value.duration;

          if (duration == Duration.zero || position < duration) {
            controller.seekTo(position);
          }
        }
      }
    }

    _positionRestored = true;
  }

  void _saveProgress() {
    if (!mounted) return;

    int watchedSeconds;

    if (_isYoutube) {
      final controller = _youtubeController;

      if (controller == null || !controller.value.isReady) {
        return;
      }

      watchedSeconds = controller.value.position.inSeconds;
    } else {
      final controller = _networkController;

      if (controller == null || !controller.value.isInitialized) {
        return;
      }

      watchedSeconds = controller.value.position.inSeconds;
    }

    if (watchedSeconds <= 0) return;

    final userId = context.read<UserCubit>().userId;

    if (userId == null) return;

    log(
      '[VIDEO_PROGRESS] '
      'lesson=${widget.lessonId} '
      'seconds=$watchedSeconds',
    );

    final cubit = context.read<LessonsCubit>();

    if (cubit.isClosed) return;

    cubit.updateLessonProgress(
      lessonId: widget.lessonId,
      courseId: widget.courseId,
      userId: userId,
      watchedSeconds: watchedSeconds,
    );
  }

  Future<void> _toggleNetworkPlayback() async {
    final controller = _networkController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openFullScreen() async {
    if (!mounted) return;

    if (_isYoutube) {
      await _openYoutubeFullScreen();
    } else {
      await _openNetworkFullScreen();
    }

    if (mounted) {
      await _enableSecureMode();
    }
  }

  Future<void> _openYoutubeFullScreen() async {
    final controller = _youtubeController;

    if (controller == null) return;

    final currentSecond = controller.value.position.inSeconds;
    final wasPlaying = controller.value.isPlaying;

    controller.pause();

    final returnedSecond = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenYoutubePage(
          videoId: _youtubeId!,
          startAt: currentSecond,
          autoPlay: wasPlaying,
        ),
      ),
    );

    if (!mounted) return;

    if (returnedSecond != null) {
      controller.seekTo(Duration(seconds: returnedSecond));
    }

    if (wasPlaying) {
      controller.play();
    }
  }

  Future<void> _openNetworkFullScreen() async {
    final controller = _networkController;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenNetworkVideoPage(controller: controller),
      ),
    );
  }

  Widget _buildYoutube() {
    final controller = _youtubeController;

    if (controller == null) {
      return const SizedBox.shrink();
    }

    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.blueAccent,
      progressColors: const ProgressBarColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
      ),
      onReady: _restorePosition,
      bottomActions: [
        const CurrentPosition(),
        const ProgressBar(isExpanded: true),
        const RemainingDuration(),
        IconButton(
          onPressed: _openFullScreen,
          icon: const Icon(Icons.fullscreen, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildNetwork() {
    final controller = _networkController;

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return NetworkVideoControls(
      controller: controller,
      onToggle: _toggleNetworkPlayback,
      onFullscreen: _openFullScreen,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _isYoutube ? _buildYoutube() : _buildNetwork(),

        if (_isAppHidden) const ColoredBox(color: Colors.black),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _progressTimer?.cancel();

    _networkController?.removeListener(_onNetworkPlayerChanged);

    _youtubeController?.dispose();
    _networkController?.dispose();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _disableSecureMode();

    super.dispose();
  }
}
