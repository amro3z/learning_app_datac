import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatefulWidget {
  final String url;

  const PdfScreen({super.key, required this.url});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final _noScreenshot = NoScreenshot.instance;

  @override
  void initState() {
    super.initState();
    disableScreenshot();
  }

  Future<void> disableScreenshot() async {
    final result = await _noScreenshot.screenshotOff();
    log('screenshotOff: $result');
  }

  @override
  void dispose() {
    _noScreenshot.screenshotOn(); // رجوع للوضع الطبيعي
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lesson PDF")),
      body: Stack(
        children: [
          SfPdfViewer.network(widget.url),

          // 🔒 Overlay للحماية الإضافية
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withOpacity(0.02)),
            ),
          ),

          // 🔥 Watermark (اختياري لكن مهم)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.rotate(
                  angle: -0.5,
                  child: Text(
                    "PROTECTED",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white.withOpacity(0.1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
