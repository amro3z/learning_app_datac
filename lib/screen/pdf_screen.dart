import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfScreen extends StatelessWidget {
  final String url;

  const PdfScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lesson PDF")),
      body: SfPdfViewer.network(url),
    );
  }
}
