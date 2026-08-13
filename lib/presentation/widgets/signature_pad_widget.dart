import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:baghdad_bullion_house/core/core_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Draw-in signature box with clear + PNG export for backend upload.
class SignaturePadWidget extends StatefulWidget {
  final GlobalKey repaintKey;
  final ValueChanged<bool>? onSignatureChanged;

  const SignaturePadWidget({
    super.key,
    required this.repaintKey,
    this.onSignatureChanged,
  });

  @override
  State<SignaturePadWidget> createState() => SignaturePadWidgetState();
}

class SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  bool get hasSignature =>
      _strokes.any((stroke) => stroke.length > 1) ||
      _currentStroke.length > 1;

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
    widget.onSignatureChanged?.call(false);
  }

  Future<Uint8List?> exportPngBytes() async {
    final boundary = widget.repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  void _notifySignatureChanged() {
    widget.onSignatureChanged?.call(hasSignature);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget.repaintKey,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _currentStroke = [details.localPosition];
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _currentStroke = [..._currentStroke, details.localPosition];
          });
          _notifySignatureChanged();
        },
        onPanEnd: (_) {
          setState(() {
            if (_currentStroke.isNotEmpty) {
              _strokes.add(_currentStroke);
            }
            _currentStroke = [];
          });
          _notifySignatureChanged();
        },
        child: CustomPaint(
          painter: _SignaturePainter(
            strokes: _strokes,
            currentStroke: _currentStroke,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: hasSignature
                ? const SizedBox.shrink()
                : GetGenericText(
                    text: Directionality.of(context) == TextDirection.rtl
                        ? 'وقع هنا'
                        : 'Sign here',
                    fontSize: sizes!.responsiveFont(phoneVal: 14, tabletVal: 16),
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;

  _SignaturePainter({
    required this.strokes,
    required this.currentStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
  ..color = Colors.black
  ..strokeWidth = 2.5
  ..strokeCap = StrokeCap.round
  ..style = PaintingStyle.stroke;

    for (final stroke in [...strokes, currentStroke]) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.currentStroke != currentStroke;
  }
}
