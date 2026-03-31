import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class SecurePdfViewer extends StatefulWidget {
  final String noteurl;
  final String name;

  const SecurePdfViewer({super.key, required this.noteurl,required this.name,});

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
        Uri.parse(widget.noteurl),
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
        error = "Error loading PDF : $e";
        isLoading = false;
      });
    }
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
      appBar: AppBar(title:  Text(widget.name), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : _buildPdfViewer(),
    );
  }
}
