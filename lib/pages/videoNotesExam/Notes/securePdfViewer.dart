import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class SecurePdfViewer extends StatefulWidget {
  final String noteId;

  const SecurePdfViewer({super.key, required this.noteId});

  @override
  State<SecurePdfViewer> createState() => _SecurePdfViewerState();
}

class _SecurePdfViewerState extends State<SecurePdfViewer> {
  Uint8List? pdfBytes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(
        Uri.parse("https://your-api.com/get-note/${widget.noteId}"),
        headers: {"Authorization": "Bearer YOUR_TOKEN"},
      );

      if (response.statusCode == 200) {
        setState(() {
          pdfBytes = response.bodyBytes;
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load PDF";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error loading PDF";
        isLoading = false;
      });
    }
  }

  Widget _buildWatermark() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: 0.08,
          child: Center(
            child: Transform.rotate(
              angle: -0.5,
              child: const Text(
                "Crescent",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfViewer() {
    return SfPdfViewer.memory(
      pdfBytes!,
      canShowScrollHead: false,
      canShowPaginationDialog: false,
      enableTextSelection: false,
      enableDoubleTapZooming: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Note"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : Stack(children: [_buildPdfViewer(), _buildWatermark()]),
    );
  }
}
