import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ImageCropHelper {
  static Future<String?> cropImage(
    BuildContext context,
    String imagePath, {
    required double aspectRatio,
  }) async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageCropPage(imagePath: imagePath, aspectRatio: aspectRatio),
      ),
    );
  }
}

class ImageCropPage extends StatefulWidget {
  final String imagePath;
  final double aspectRatio;
  const ImageCropPage({
    super.key,
    required this.imagePath,
    required this.aspectRatio,
  });

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  final GlobalKey _imageKey = GlobalKey();
  Offset _cropPosition = Offset.zero;
  Size _containerSize = Size.zero;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCropArea();
    });
  }

  void _initializeCropArea() {
    final RenderBox? renderBox =
        _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _containerSize = renderBox.size;

        _cropPosition = Offset(
          (_containerSize.width - _getCropWidth()) / 2,
          (_containerSize.height - _getCropHeight()) / 2,
        );
      });
    }
  }

  double _getCropWidth() {
    final maxWidthBasedCropHeight = _containerSize.width / widget.aspectRatio;
    final maxHeightBasedCropWidth = _containerSize.height * widget.aspectRatio;
    if (maxWidthBasedCropHeight <= _containerSize.height) {
      return _containerSize.width;
    } else {
      return maxHeightBasedCropWidth;
    }
  }

  double _getCropHeight() {
    return _getCropWidth() / widget.aspectRatio;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      double newX = _cropPosition.dx + details.delta.dx;
      double newY = _cropPosition.dy + details.delta.dy;

      newX = newX.clamp(0.0, _containerSize.width - _getCropWidth());
      newY = newY.clamp(0.0, _containerSize.height - _getCropHeight());

      _cropPosition = Offset(newX, newY);
    });
  }

  Future<void> _cropAndSave() async {
    setState(() => _isProcessing = true);

    try {
      final File imageFile = File(widget.imagePath);
      final ui.Image image = await _loadImage(imageFile);
      final RenderBox renderBox =
          _imageKey.currentContext!.findRenderObject() as RenderBox;
      final Size displaySize = renderBox.size;
      final double scaleX = image.width / displaySize.width;
      final double scaleY = image.height / displaySize.height;
      final Rect cropRect = Rect.fromLTWH(
        _cropPosition.dx * scaleX,
        _cropPosition.dy * scaleY,
        _getCropWidth() * scaleX,
        _getCropHeight() * scaleY,
      );

      final ui.Image croppedImage = await _cropImageFromRect(image, cropRect);
      final String croppedPath = await _saveImage(croppedImage);

      if (mounted) {
        Navigator.pop(context, croppedPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cropping image: $e')));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<ui.Image> _loadImage(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<ui.Image> _cropImageFromRect(ui.Image image, Rect cropRect) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImageRect(
      image,
      cropRect,
      Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
      Paint(),
    );

    final picture = recorder.endRecording();
    return await picture.toImage(
      cropRect.width.toInt(),
      cropRect.height.toInt(),
    );
  }

  Future<String> _saveImage(ui.Image image) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/cropped_$timestamp.png';

    final file = File(filePath);
    await file.writeAsBytes(buffer);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _cropAndSave),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Image.file(
                    File(widget.imagePath),
                    key: _imageKey,
                    fit: BoxFit.contain,
                  ),

                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_containerSize != constraints.biggest) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _initializeCropArea();
                          });
                        }

                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size.infinite,
                              painter: CropOverlayPainter(
                                cropRect: Rect.fromLTWH(
                                  _cropPosition.dx,
                                  _cropPosition.dy,
                                  _getCropWidth(),
                                  _getCropHeight(),
                                ),
                              ),
                            ),

                            // Draggable crop frame
                            Positioned(
                              left: _cropPosition.dx,
                              top: _cropPosition.dy,
                              child: GestureDetector(
                                onPanUpdate: _onPanUpdate,
                                child: Container(
                                  width: _getCropWidth(),
                                  height: _getCropHeight(),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Text(
              'Drag the frame to select the area you want to crop (${widget.aspectRatio.toStringAsFixed(2)} ratio)',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class CropOverlayPainter extends CustomPainter {
  final Rect cropRect;

  CropOverlayPainter({required this.cropRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect;
  }
}
