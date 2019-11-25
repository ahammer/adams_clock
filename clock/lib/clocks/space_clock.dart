import 'dart:math';
import 'dart:ui';
import 'package:adams_clock/util/animated_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:adams_clock/util/extensions.dart';
import 'dart:ui' as ui;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:adams_clock/util/image_loader.dart';

const List<String> images = [
  "earth",
  "moon",
  "sun_1",
  "sun_2",
  "sun_3",
  "sun_4",
  "stars"
];

final kRandom = Random();

class Star {
  final x = kRandom.nextDouble() - 0.5,
      y = kRandom.nextDouble() - 0.5,
      z = kRandom.nextDouble();

  // Z changes over time
  // Time is a double represent time in ms since the epoch
  double zForTime(double time) => (z - (time / 24)).fraction();

  Offset project(double time, vector.Matrix4 perspective) {
    vector.Vector3 v = vector.Vector3(x, y, zForTime(time))
      ..applyProjection(perspective);
    return v.toOffset();
  }
}

class ClockScene extends StatelessWidget {
  final ClockModel model;
  ClockScene({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) => AnimatedPaint(
        painter: () => ClockPainter(),
      );
}

class ClockPainter extends AnimatedPainter {
  final Map<String, ui.Image> imageMap = Map();

  final TextPainter loadingTextPaint = TextPainter(
    text: TextSpan(
        text: "Loading", style: TextStyle(color: Colors.white, fontSize: 10)),
  );

  // These are my paintbrushes
  final Paint standardPaint = Paint()..color = Colors.black;
  Paint get sunBasePaint => Paint()..color = Colors.orange;
  Paint get sunLayer1Paint => Paint()..blendMode = BlendMode.hardLight;
  Paint get sunLayer2Paint => Paint()..blendMode = BlendMode.multiply;
  Paint get sunLayer3Paint => Paint()..blendMode = BlendMode.multiply;
  final Paint starsPaint = Paint()
    ..color = Colors.white
    ..strokeWidth = 1;

  final List<Star> stars = List.generate(3000, (idx) => Star());

  bool get loaded => imageMap.length == images.length;
  double time = 0;
  double lastFrameTime;

  @override
  void init() async {
    for (int i = 0; i < images.length; i++) {
      final image = images[i];
      imageMap[image] = await loadImageFromAsset(image);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (lastFrameTime == null) {
      lastFrameTime = DateTime.now().microsecondsSinceEpoch / 1000000.0;
    }
    double timeNow = DateTime.now().microsecondsSinceEpoch / 1000000.0;
    double deltaTime = timeNow - lastFrameTime;

    time += deltaTime;

    if (!loaded) {
      drawLoadingScreen(canvas, size);
    } else {
      drawSpace(canvas, size);
    }
  }

  ///
  /// A very simple loading scree
  ///
  void drawLoadingScreen(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), standardPaint);
    TextSpan span = new TextSpan(
        style: new TextStyle(color: Colors.white),
        text:
            "Loading (${(imageMap.length / images.length.toDouble() * 100).toInt()}%)....");
    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, new Offset(5.0, 5.0));
  }

  void drawSpace(Canvas canvas, Size size) {
    final time = DateTime.now();

    ///
    /// We prepare all the math of the clock layout/orientation here
    ///

    // This offset aligns the rotation so 12:00:00am everything will be at the top.
    double angleOffset = pi / 2;

    // The moon Orbit Angle, it rotates the earth once per minute
    double moonOrbit = (time.second * 1000 + time.millisecond) / 60000 * 2 * pi;

    // The earth orbit, once per hour (millis precision for animations to not be choppy)
    double earthOrbit =
        (time.minute * 60 * 1000 + time.second * 1000 + time.millisecond) /
            3600000 *
            2 *
            pi;

    // The suns orbit of the screen once per day
    double sunOrbit = (time.hour / 12.0) * 2 * pi + (1 / 12.0 * earthOrbit);

    // These are the offsets from center for the earth/sun/moon
    // They travel in an Oval, in proportion to screen size
    // The moon also travels
    double osunx = cos(sunOrbit - angleOffset) * size.width * 1.2;
    double osuny = sin(sunOrbit - angleOffset) * size.height * 1.7;

    double oearthx = cos(earthOrbit - angleOffset) * size.width / 3;
    double oearthy = sin(earthOrbit - angleOffset) * size.height / 3;

    double omoonx = cos(moonOrbit - angleOffset) * size.width / 4;
    double omoony = sin(moonOrbit - angleOffset) * size.height / 4;

    final sunOffset = Offset(size.width / 2 + osunx, size.height / 2 + osuny);
    final sunDiameter = size.width * 2;

    drawBackground(canvas, size, earthOrbit);
    drawStars(canvas, size);
    drawSun(canvas, sunOffset, sunDiameter, sunOrbit, earthOrbit);
    drawEarth(canvas, size, oearthx, oearthy, earthOrbit);
    drawMoon(canvas, size, oearthx, omoonx, oearthy, omoony, earthOrbit);
  }

  void drawMoon(Canvas canvas, Size size, double ox, double ox2, double oy,
      double oy2, double earthOrbit) {
    imageMap["moon"].drawRotatedSquare(
        canvas: canvas,
        size: size.width / 3,
        offset: Offset(size.width / 2 + ox + ox2, size.height / 2 + oy + oy2),
        rotation: earthOrbit * 20,
        paint: standardPaint);
  }

  void drawEarth(
      Canvas canvas, Size size, double ox, double oy, double earthOrbit) {
    imageMap["earth"].drawRotatedSquare(
        canvas: canvas,
        size: size.width * 0.75,
        offset: Offset(size.width / 2 + ox, size.height / 2 + oy),
        rotation: earthOrbit * 4,
        paint: standardPaint);
  }

  void drawSun(Canvas canvas, Offset sunOffset, double sunDiameter,
      double sunRotation, double earthOrbit) {
    canvas.drawCircle(sunOffset, sunDiameter / 2 * 0.95, sunBasePaint);
    imageMap["sun_1"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: earthOrbit * 5 ,
        paint: sunLayer1Paint);

    imageMap["sun_4"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: earthOrbit * -5,
        paint: sunLayer1Paint);

    imageMap["sun_2"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: earthOrbit * 4,
        paint: sunLayer2Paint);

    imageMap["sun_3"].drawRotatedSquare(
        canvas: canvas,
        size: sunDiameter,
        offset: sunOffset,
        rotation: earthOrbit * -4,
        paint: sunLayer3Paint);
  }

  void drawBackground(Canvas canvas, Size size, double earthOrbit) {
    imageMap["stars"].drawRotatedSquare(
        canvas: canvas,
        size: size.width + size.height,
        offset: Offset(size.width / 2, size.height / 2),
        rotation: earthOrbit * -5,
        paint: standardPaint);
  }

  void drawStars(Canvas canvas, Size size) {
    final projection =
        vector.makePerspectiveMatrix(140, size.width / size.height, 0, 1);
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    int steps = 10;
    double intervalSize = 1.0 / steps;

    List.generate(steps, (idx) => idx / steps.toDouble()).forEach((interval) {
      starsPaint
        ..color = Colors.white.withOpacity(1 - interval)
        ..strokeWidth = interval * 2 + 1;

      canvas.drawPoints(
          PointMode.points,
          stars
              .where((star) {
                double z = star.zForTime(time);
                return (z > interval && z < (interval + intervalSize));
              })
              .map((star) => star
                  .project(time, projection)
                  .translate(0.5, 0.5)
                  .scale(size.width, size.height))
              .toList(),
          starsPaint);
    });
  }
}
