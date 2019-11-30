import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

final kTargetRect = Rect.fromCenter(center: Offset.zero, width: 1, height: 1);

extension StringHelpers on String {
  String charAt(int idx) => this.substring(idx, idx+1);
}
///
/// Image Helpers
///
extension ImageHelpers on ui.Image {
  ///
  /// Draws a Square Image rotated at offset around it's axis
  ///
  void drawRotatedSquare(
      {Canvas canvas,
      double size,
      Offset offset,
      double rotation,
      Paint paint}) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.save();
    canvas.rotate(rotation);
    canvas.scale(size);
    canvas.drawImageRect(this, bounds(), kTargetRect, paint);
    canvas.restore();
    canvas.restore();
  }

  ///
  /// Gets the bounds of this image
  ///
  Rect bounds() =>
      Rect.fromLTRB(0, 0, this.width.toDouble(), this.height.toDouble());
}

///
/// Math Helpers
///
extension DoubleHelpers on double {
  ///
  /// Gets the fraction of a double, e.g. (1.234) => 0.234
  ///
  double fraction() => this - this.floorToDouble();
}

extension VectorHelpers on vector.Vector3 {
  //Collapse a vector to a offset
  Offset toOffset() => Offset(this.x, this.y);
}

///
/// Helpers for the ClockModel
/// 
extension ClockModelHelpers on ClockModel {

  // Want to show the weather as a Emoji
  String  get weatherEmoji {
    switch (this.weatherCondition) {      
      case WeatherCondition.cloudy:
       return '☁️';
      case WeatherCondition.foggy:      
        return '🌫️';
      case WeatherCondition.rainy:      
        return '🌧️';
      case WeatherCondition.snowy:      
        return '🌨️';
      case WeatherCondition.sunny:      
        return '☀️';
      case WeatherCondition.thunderstorm:      
        return '⛈️';
      case WeatherCondition.windy:      
        return '🌬️';
    }
    return "";
  }
}

extension TextStyleHelpers on TextStyle {
    withNovaMono() => this.copyWith(fontFamily: "NovaMono");
}

///
/// Pull arguments out of a ModalRoute and pass them to a builder function
///
/// Usage:
/// 
/// ArgumentBuilder<YourType>((context, yourtype) => Text(yourtype.getSomeField())
/// 
typedef ArgumentBuilder<T>(BuildContext context, T argument);
class PassNamedArguments<T> extends StatelessWidget {  
  final ArgumentBuilder<T> builder;

  const PassNamedArguments(this.builder, {Key key}) : super(key: key);

  @override
  build(BuildContext context) => builder(context, ModalRoute.of(context).settings.arguments);
}

