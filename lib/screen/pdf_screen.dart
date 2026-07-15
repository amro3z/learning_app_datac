import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:training/helper/base.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatefulWidget {
  final String url;

  const PdfScreen({super.key, required this.url});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> with WidgetsBindingObserver {
  static const MethodChannel _secureChannel = MethodChannel('secure_screen');

  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  bool _isAppHidden = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enableSecureMode();
  }

  Future<void> _enableSecureMode() async {
    try {
      await _secureChannel.invokeMethod('enable');

      final result = await _noScreenshot.screenshotOff();

      log('Secure mode enabled');
      log('screenshotOff: $result');
    } catch (e) {
      log('Enable secure mode error: $e');
    }
  }

  Future<void> _disableSecureMode() async {
    try {
      await _secureChannel.invokeMethod('disable');

      final result = await _noScreenshot.screenshotOn();

      log('Secure mode disabled');
      log('screenshotOn: $result');
    } catch (e) {
      log('Disable secure mode error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _isAppHidden = true);
    }

    if (state == AppLifecycleState.resumed) {
      setState(() => _isAppHidden = false);
      _enableSecureMode();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableSecureMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Lesson PDF")),
      body: Stack(
        children: [
          SfPdfViewer.network(widget.url),

          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    "PROTECTED",
                    style: TextStyle(
                      fontSize: getScreenWidth(context) * 0.10256,
                      color: Colors.white.withOpacity(0.10),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_isAppHidden)
            Positioned.fill(child: ColoredBox(color: Colors.black)),
        ],
      ),
    );
  }
}
