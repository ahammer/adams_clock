import 'package:flutter/material.dart';

/// Builds an AnimatedPainter object
typedef PainterBuilder = AnimatedPainter Function();

///
/// AnimatedPainter
///
/// Implement this interface to get an animated Canvas.
/// Use with AnimatedPaint() widget
///
/// Used by SpaceClock to paint the scene
/// paint() will be called as fast as possible
abstract class AnimatedPainter {

  /// Initialize the Painter (e.g. Load Images)
  void init();

  /// Paint to the canvas
  void paint(Canvas canvas, Size size);
}

///
/// AnimatedPaint
///
/// Provide a Painter() and this class will paint it
class AnimatedPaint extends StatefulWidget {

  /// The Painter interface we are using
  final PainterBuilder painter;

  /// Construct an AnimatedPaint to draw a AnimatedPainter
  const AnimatedPaint({Key key, @required this.painter}) : super(key: key);

  @override
  _AnimatedPainterState createState() => _AnimatedPainterState();
}

class _AnimatedPainterState extends State<AnimatedPaint>
    with SingleTickerProviderStateMixin {
  AnimatedPainter painter;
  AnimationController controller;

  // Every time the painter changes, track that change and init the new painter
  @override
  void didChangeDependencies() {
    painter = widget.painter();
    painter.init();
    super.didChangeDependencies();
  }

  // Start a
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat();
  }

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
          painter: _CustomPaintProxy(painter, repaint: controller)));
}

///
/// _CustomPaintProxy
///
/// Adapts a CustomPaint to the AnimatedPaint interface
class _CustomPaintProxy extends CustomPainter {
  final AnimatedPainter painter;
  _CustomPaintProxy(this.painter, {Listenable repaint})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) => painter.paint(canvas, size);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
