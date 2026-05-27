import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:agrobravo/core/tokens/app_colors.dart';
import 'package:agrobravo/core/tokens/app_text_styles.dart';

/// A modal dialog that lets the user pan & zoom an image, then crops the
/// circular region **exactly** as shown in the preview and returns the result
/// as [Uint8List] (PNG bytes).
class ImageCropperModal extends StatefulWidget {
  final ImageProvider imageProvider;

  const ImageCropperModal({super.key, required this.imageProvider});

  /// Shows the modal and returns the cropped PNG bytes, or `null` if cancelled.
  static Future<Uint8List?> show(
    BuildContext context, {
    required ImageProvider imageProvider,
  }) {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ImageCropperModal(imageProvider: imageProvider),
    );
  }

  @override
  State<ImageCropperModal> createState() => _ImageCropperModalState();
}

class _ImageCropperModalState extends State<ImageCropperModal> {
  static const double _containerSize = 280;
  static const double _cropSize = 180;
  static const double _minZoom = 0.65;
  static const double _maxZoom = 3.0;
  static const int _outputSize = 300;

  double _zoom = _minZoom;
  Offset _offset = Offset.zero;
  Offset _dragStart = Offset.zero;
  bool _isDragging = false;

  Size _imgDisplaySize = const Size(_containerSize, _containerSize);
  bool _isProcessing = false;

  /// Key for the RepaintBoundary that wraps ONLY the image layer.
  /// We capture this boundary to get the exact rendered pixels.
  final GlobalKey _imageLayerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  /// Resolve the image just to get its aspect ratio for display sizing.
  void _resolveImageSize() {
    final stream = widget.imageProvider.resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((info, _) {
      if (!mounted) return;
      final aspect = info.image.width / info.image.height;
      double w = _containerSize;
      double h = _containerSize;
      if (aspect > 1) {
        h = _containerSize;
        w = _containerSize * aspect;
      } else {
        w = _containerSize;
        h = _containerSize / aspect;
      }
      setState(() {
        _imgDisplaySize = Size(w, h);
      });
    }));
  }

  Offset _clamp(Offset raw, double zoom, Size imgSize) {
    final zw = imgSize.width * zoom;
    final zh = imgSize.height * zoom;
    final halfCrop = _cropSize / 2;
    final maxX = max((zw / 2) - halfCrop, 0.0);
    final maxY = max((zh / 2) - halfCrop, 0.0);
    return Offset(
      raw.dx.clamp(-maxX, maxX),
      raw.dy.clamp(-maxY, maxY),
    );
  }

  void _onZoomChanged(double newZoom) {
    setState(() {
      _zoom = newZoom;
      _offset = _clamp(_offset, newZoom, _imgDisplaySize);
    });
  }

  // ── Gesture handling ───────────────────────────────────────────────────

  void _onPanStart(DragStartDetails d) {
    _isDragging = true;
    _dragStart = d.localPosition - _offset;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (!_isDragging) return;
    setState(() {
      final raw = d.localPosition - _dragStart;
      _offset = _clamp(raw, _zoom, _imgDisplaySize);
    });
  }

  void _onPanEnd(DragEndDetails _) => _isDragging = false;

  // ── Crop via RepaintBoundary screenshot ─────────────────────────────────

  Future<void> _performCrop() async {
    setState(() => _isProcessing = true);

    try {
      // Wait a frame so the UI updates before capture
      await Future.delayed(const Duration(milliseconds: 50));

      final boundary = _imageLayerKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        if (mounted) setState(() => _isProcessing = false);
        return;
      }
      if (!mounted) return;

      // Capture the image layer at high DPI for quality
      final dpr = MediaQuery.of(context).devicePixelRatio;
      final capturedImage = await boundary.toImage(pixelRatio: dpr);

      // The captured image is containerSize * dpr pixels.
      // The crop circle is centered, with size _cropSize * dpr in captured pixels.
      final capturedW = capturedImage.width.toDouble();
      final capturedH = capturedImage.height.toDouble();
      final cropPx = _cropSize * dpr;
      final cropLeftPx = (capturedW - cropPx) / 2;
      final cropTopPx = (capturedH - cropPx) / 2;

      // Draw the crop region into the output canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final outputSize = _outputSize.toDouble();

      canvas.drawImageRect(
        capturedImage,
        Rect.fromLTWH(cropLeftPx, cropTopPx, cropPx, cropPx),
        Rect.fromLTWH(0, 0, outputSize, outputSize),
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(_outputSize, _outputSize);
      final byteData =
          await croppedImage.toByteData(format: ui.ImageByteFormat.png);

      if (!mounted) return;
      Navigator.of(context).pop(byteData?.buffer.asUint8List());
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao processar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ajustar Foto de Perfil',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                height: 20,
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 4),

              // Viewport
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: SizedBox(
                    width: _containerSize,
                    height: _containerSize,
                    child: Stack(
                      children: [
                        // Image layer — wrapped in RepaintBoundary for capture
                        RepaintBoundary(
                          key: _imageLayerKey,
                          child: Container(
                            width: _containerSize,
                            height: _containerSize,
                            color: Colors.black,
                            child: Center(
                              child: Transform.translate(
                                offset: _offset,
                                child: Transform.scale(
                                  scale: _zoom,
                                  child: SizedBox(
                                    width: _imgDisplaySize.width,
                                    height: _imgDisplaySize.height,
                                    child: Image(
                                      image: widget.imageProvider,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Mask overlay (semi-transparent outside circle)
                        IgnorePointer(
                          child: CustomPaint(
                            size: const Size(_containerSize, _containerSize),
                            painter: _CropOverlayPainter(
                              cropRadius: _cropSize / 2,
                            ),
                          ),
                        ),
                        // Crop circle border
                        Center(
                          child: IgnorePointer(
                            child: Container(
                              width: _cropSize,
                              height: _cropSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Zoom slider
              Row(
                children: [
                  Icon(
                    Icons.zoom_out,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        thumbColor: AppColors.primary,
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor:
                            colorScheme.onSurface.withValues(alpha: 0.12),
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 7,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                      ),
                      child: Slider(
                        value: _zoom,
                        min: _minZoom,
                        max: _maxZoom,
                        onChanged: _onZoomChanged,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.zoom_in,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isProcessing ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.onSurface,
                        side: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancelar',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _performCrop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Salvar',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws the semi-transparent overlay around the circular crop area.
/// Uses a single saveLayer to avoid double-darkening.
class _CropOverlayPainter extends CustomPainter {
  final double cropRadius;

  _CropOverlayPainter({required this.cropRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
      rect,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      center,
      cropRadius,
      Paint()..blendMode = BlendMode.clear,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
