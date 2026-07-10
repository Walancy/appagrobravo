import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/extensions/build_context_l10n.dart';

/// Tipo de recorte: círculo (avatar) ou retângulo 16:9 (capa).
enum CropShape { circle, rectangle169 }

/// Full-screen image cropper — pinch to zoom, drag to pan, no distortion.
/// Returns cropped PNG bytes, or null if cancelled.
class ImageCropperModal extends StatefulWidget {
  final ImageProvider imageProvider;
  final CropShape cropShape;

  const ImageCropperModal({
    super.key,
    required this.imageProvider,
    this.cropShape = CropShape.circle,
  });

  static Future<Uint8List?> show(
    BuildContext context, {
    required ImageProvider imageProvider,
    CropShape cropShape = CropShape.circle,
  }) {
    return Navigator.of(context).push<Uint8List>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (ctx, _, __) =>
            ImageCropperModal(imageProvider: imageProvider, cropShape: cropShape),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<ImageCropperModal> createState() => _ImageCropperModalState();
}

class _ImageCropperModalState extends State<ImageCropperModal> {
  static const int _outputPx = 800;

  ui.Image? _image;
  bool _isProcessing = false;

  // The scale that makes the image just cover the crop area (user zoom = 1×).
  double _baseScale = 1.0;
  // Additional user zoom (1.0 = no extra zoom, max 4.0).
  double _userScale = 1.0;
  // Pan offset in display coordinates (image center relative to viewport center).
  Offset _translate = Offset.zero;

  // Saved at gesture start for correct anchoring.
  double _gestureBaseUserScale = 1.0;
  Offset _gestureBaseTranslate = Offset.zero;
  Offset _gestureFocalStart = Offset.zero;

  // Set in build() from MediaQuery — usado para circular.
  double _cropRadius = 150;
  // Para retangular 16:9
  late double _cropW;
  late double _cropH;

  bool get _isRect => widget.cropShape == CropShape.rectangle169;

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
    if (_isRect) {
      _baseScale = max(
        _cropW / _image!.width,
        _cropH / _image!.height,
      );
    } else {
      final diameter = _cropRadius * 2;
      _baseScale = max(
        diameter / _image!.width,
        diameter / _image!.height,
      );
    }
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
    final double areaW = _isRect ? _cropW : _cropRadius * 2;
    final double areaH = _isRect ? _cropH : _cropRadius * 2;
    final maxX = max(0.0, (displayW - areaW) / 2);
    final maxY = max(0.0, (displayH - areaH) / 2);
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

      final srcCenterX = imgW / 2 - _translate.dx / _totalScale;
      final srcCenterY = imgH / 2 - _translate.dy / _totalScale;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final int outW;
      final int outH;
      final Rect srcRect;

      if (_isRect) {
        // Crop retangular 16:9
        final srcHalfW = _cropW / 2 / _totalScale;
        final srcHalfH = _cropH / 2 / _totalScale;
        srcRect = Rect.fromLTWH(
          srcCenterX - srcHalfW,
          srcCenterY - srcHalfH,
          srcHalfW * 2,
          srcHalfH * 2,
        );
        outW = _outputPx;
        outH = (_outputPx * 9 / 16).round();
      } else {
        // Crop circular (quadrado recortado depois)
        final srcRadius = _cropRadius / _totalScale;
        srcRect = Rect.fromLTWH(
          srcCenterX - srcRadius,
          srcCenterY - srcRadius,
          srcRadius * 2,
          srcRadius * 2,
        );
        outW = _outputPx;
        outH = _outputPx;
      }

      canvas.drawImageRect(
        _image!,
        srcRect,
        Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final cropped = await picture.toImage(outW, outH);
      final bytes = await cropped.toByteData(format: ui.ImageByteFormat.png);

      if (!mounted) return;
      Navigator.of(context).pop(bytes?.buffer.asUint8List());
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        if (kDebugMode) debugPrint('[ImageCropper] _performCrop error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.cropperProcessError),
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
    _cropW = size.width - 32;
    _cropH = _cropW * 9 / 16;

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
                  Expanded(
                    child: Text(
                      _isRect
                          ? context.l10n.cropperAdjustCover
                          : context.l10n.cropperAdjustPhoto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  // Espaço para equilibrar o iconbutton
                  if (_isProcessing)
                    const SizedBox(
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
                  else
                    const SizedBox(width: 48),
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
                          painter: _isRect
                              ? _CropPainterRect(
                                  image: _image!,
                                  translate: _translate,
                                  totalScale: _totalScale,
                                  cropW: _cropW,
                                  cropH: _cropH,
                                )
                              : _CropPainter(
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
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                context.l10n.cropperGestureHint,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ),

            // ── Action buttons ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Row(
                children: [
                  // Cancelar
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed:
                            _isProcessing ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          context.l10n.commonCancel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirmar
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _performCrop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                context.l10n.cropperUsePhoto,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the image + circular overlay in a single pass.
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

/// Draws the image + rectangular 16:9 overlay in a single pass.
class _CropPainterRect extends CustomPainter {
  final ui.Image image;
  final Offset translate;
  final double totalScale;
  final double cropW;
  final double cropH;

  const _CropPainterRect({
    required this.image,
    required this.translate,
    required this.totalScale,
    required this.cropW,
    required this.cropH,
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

    // ── Dark overlay with rectangular hole ───────────────────────────────
    final cropRect = Rect.fromCenter(center: center, width: cropW, height: cropH);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawRect(cropRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // ── Rectangle border ──────────────────────────────────────────────────
    canvas.drawRect(
      cropRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── Rule-of-thirds guides ─────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 0.8;
    for (int i = 1; i <= 2; i++) {
      final x = cropRect.left + cropW * i / 3;
      final y = cropRect.top + cropH * i / 3;
      canvas.drawLine(Offset(x, cropRect.top), Offset(x, cropRect.bottom), gridPaint);
      canvas.drawLine(Offset(cropRect.left, y), Offset(cropRect.right, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(_CropPainterRect old) =>
      old.translate != translate ||
      old.totalScale != totalScale ||
      old.image != image;
}
