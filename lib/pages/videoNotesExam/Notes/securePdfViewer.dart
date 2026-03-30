import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
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

  @override
  void initState() {
    super.initState();
    _secureScreen();
    _loadPdf();
  }

  Future<void> _secureScreen() async {
    await FlutterWindowManager.addFlags(
      FlutterWindowManager.FLAG_SECURE,
    );
  }

  Future<void> _loadPdf() async {
    final response = await http.get(
      Uri.parse("https://your-api.com/get-note/${widget.noteId}"),
      headers: {
        "Authorization": "Bearer YOUR_TOKEN",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        pdfBytes = response.bodyBytes;
      });
    }
  }

  @override
  void dispose() {
    FlutterWindowManager.clearFlags(
      FlutterWindowManager.FLAG_SECURE,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Note ")),
      body: pdfBytes == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SfPdfViewer.memory(
                  pdfBytes!,
                  canShowScrollHead: false,
                  canShowPaginationDialog: false,
                  enableTextSelection: false,
                  enableDoubleTapZooming: false,
                ),

                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.1,
                      child: Center(
                        child: Text(
                          "Crescent",
                          style: const TextStyle(
                            fontSize: 40,
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