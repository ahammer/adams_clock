import 'package:flutter/material.dart';

typedef AnimatedPainter PainterBuilder();

///
/// AnimatedPainter
///
/// Implement this interface to get an animated Canvas.
/// Use with AnimatedPaint() widget
/// 
/// Used by SpaceClock to paint the scene
/// paint() will be called as fast as possible
abstract class AnimatedPainter {
  void init();
  void paint(Canvas canvas, Size size);
}

///
/// AnimatedPaint
///
/// Provide a Painter() and this class will paint it
class AnimatedPaint extends StatefulWidget {
  final PainterBuilder painter;

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
  
  // Start a looping vsync animation to sync the drawing too
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: const Duration(seconds: 1), vsync: this)
          ..repeat();
  }

  // Clean up the animation
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
        child: AnimatedBuilder(
            animation: Tween<double>(begin: 0, end: 1).animate(controller),
            builder: (BuildContext context, Widget child) =>
                CustomPaint(painter: _CustomPaintProxy(painter))));
}

/// 
/// _CustomPaintProxy
/// 
/// Adapts a CustomPaint to the AnimatedPaint interface
class _CustomPaintProxy extends CustomPainter {
  final AnimatedPainter painter;
  _CustomPaintProxy(this.painter);

  @override
  void paint(Canvas canvas, Size size) => painter.paint(canvas, size);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
