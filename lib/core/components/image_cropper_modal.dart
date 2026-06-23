import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';

/// Full-screen image cropper — pinch to zoom, drag to pan, no distortion.
/// Returns cropped PNG bytes, or null if cancelled.
class ImageCropperModal extends StatefulWidget {
  final ImageProvider imageProvider;

  const ImageCropperModal({super.key, required this.imageProvider});

  static Future<Uint8List?> show(
    BuildContext context, {
    required ImageProvider imageProvider,
  }) {
    return Navigator.of(context).push<Uint8List>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (ctx, _, __) =>
            ImageCropperModal(imageProvider: imageProvider),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<ImageCropperModal> createState() => _ImageCropperModalState();
}

class _ImageCropperModalState extends State<ImageCropperModal> {
  static const int _outputPx = 400;

  ui.Image? _image;
  bool _isProcessing = false;

  // The scale that makes the image just cover the crop circle (user zoom = 1×).
  double _baseScale = 1.0;
  // Additional user zoom (1.0 = no extra zoom, max 4.0).
  double _userScale = 1.0;
  // Pan offset in display coordinates (image center relative to viewport center).
  Offset _translate = Offset.zero;

  // Saved at gesture start for correct anchoring.
  double _gestureBaseUserScale = 1.0;
  Offset _gestureBaseTranslate = Offset.zero;
  Offset _gestureFocalStart = Offset.zero;

  // Set in build() from MediaQuery.
  double _cropRadius = 150;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final stream = widget.imageProvider.resolve(ImageConfiguration.empty);
    late ImageStreamListener listener;
    listener = ImageStreamListener((info, _) {
      stream.removeListener(listener);
      if (!mounted) return;
      setState(() {
        _image = info.image;
        _initTransform();
      });
    });
    stream.addListener(listener);
  }

  void _initTransform() {
    if (_image == null) return;
    final diameter = _cropRadius * 2;
    _baseScale = max(
      diameter / _image!.width,
      diameter / _image!.height,
    );
    _userScale = 1.0;
    _translate = Offset.zero;
  }

  double get _totalScale => _baseScale * _userScale;

  double get _minUserScale => 1.0;
  double get _maxUserScale => 4.0;

  Offset _clamped(Offset t) {
    if (_image == null) return Offset.zero;
    final displayW = _image!.width * _totalScale;
    final displayH = _image!.height * _totalScale;
    final diameter = _cropRadius * 2;
    final maxX = max(0.0, (displayW - diameter) / 2);
    final maxY = max(0.0, (displayH - diameter) / 2);
    return Offset(t.dx.clamp(-maxX, maxX), t.dy.clamp(-maxY, maxY));
  }

  void _onScaleStart(ScaleStartDetails d) {
    _gestureBaseUserScale = _userScale;
    _gestureBaseTranslate = _translate;
    _gestureFocalStart = d.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final newUserScale =
        (_gestureBaseUserScale * d.scale).clamp(_minUserScale, _maxUserScale);

    // Pan delta in display space.
    final panDelta = d.localFocalPoint - _gestureFocalStart;

    // When scale changes, anchor the focal point so it stays fixed on the image.
    // Focal point in image space (relative to image center) at gesture start:
    //   focalOnImage = (_gestureFocalStart - viewportCenter - _gestureBaseTranslate)
    //                  / (_baseScale * _gestureBaseUserScale)
    // After scale change, that same image point should stay under the focal point:
    //   newTranslate = focalOnViewport - focalOnImage * newTotalScale - viewportCenter
    //
    // Simplified (working in offsets from viewport center):
    final scaleRatio = newUserScale / _gestureBaseUserScale;
    final scaledTranslate = _gestureBaseTranslate * scaleRatio;

    setState(() {
      _userScale = newUserScale;
      _translate = _clamped(scaledTranslate + panDelta);
    });
  }

  // ── Crop ──────────────────────────────────────────────────────────────────

  Future<void> _performCrop() async {
    if (_image == null) return;
    setState(() => _isProcessing = true);
    try {
      final imgW = _image!.width.toDouble();
      final imgH = _image!.height.toDouble();

      // Map the crop circle (centered in viewport) back to image pixel space.
      // Image center in viewport = viewportCenter + _translate.
      // Crop circle center = viewportCenter.
      // So in image coords, crop center = image_center - translate/totalScale.
      final srcCenterX = imgW / 2 - _translate.dx / _totalScale;
      final srcCenterY = imgH / 2 - _translate.dy / _totalScale;
      final srcRadius = _cropRadius / _totalScale;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final out = _outputPx.toDouble();

      canvas.drawImageRect(
        _image!,
        Rect.fromLTWH(
          srcCenterX - srcRadius,
          srcCenterY - srcRadius,
          srcRadius * 2,
          srcRadius * 2,
        ),
        Rect.fromLTWH(0, 0, out, out),
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final cropped = await picture.toImage(_outputPx, _outputPx);
      final bytes = await cropped.toByteData(format: ui.ImageByteFormat.png);

      if (!mounted) return;
      Navigator.of(context).pop(bytes?.buffer.asUint8List());
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        if (kDebugMode) debugPrint('[ImageCropper] _performCrop error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível processar a imagem. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _cropRadius = size.width * 0.43;

    // Re-init if image just loaded or crop radius changed.
    if (_image != null && _baseScale == 1.0) _initTransform();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed:
                        _isProcessing ? null : () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Ajustar foto',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  _isProcessing
                      ? const SizedBox(
                          width: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: _performCrop,
                          child: Text(
                            'Usar',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ],
              ),
            ),

            // ── Viewport ──────────────────────────────────────────────────
            Expanded(
              child: _image == null
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : GestureDetector(
                      onScaleStart: _onScaleStart,
                      onScaleUpdate: _onScaleUpdate,
                      child: SizedBox.expand(
                        child: CustomPaint(
                          painter: _CropPainter(
                            image: _image!,
                            translate: _translate,
                            totalScale: _totalScale,
                            cropRadius: _cropRadius,
                          ),
                        ),
                      ),
                    ),
            ),

            // ── Hint ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Belisque para dar zoom • Arraste para mover',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the image + overlay in a single pass — no distortion, no Widget tree overhead.
class _CropPainter extends CustomPainter {
  final ui.Image image;
  final Offset translate;
  final double totalScale;
  final double cropRadius;

  const _CropPainter({
    required this.image,
    required this.translate,
    required this.totalScale,
    required this.cropRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ── Draw image ────────────────────────────────────────────────────────
    final displayW = image.width * totalScale;
    final displayH = image.height * totalScale;
    final imgRect = Rect.fromCenter(
      center: center + translate,
      width: displayW,
      height: displayH,
    );
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      imgRect,
      Paint()..filterQuality = FilterQuality.medium,
    );

    // ── Dark overlay with circular hole ───────────────────────────────────
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawCircle(center, cropRadius, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // ── Circle border ─────────────────────────────────────────────────────
    canvas.drawCircle(
      center,
      cropRadius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.translate != translate ||
      old.totalScale != totalScale ||
      old.image != image;
}
