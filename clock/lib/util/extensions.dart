import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

///
/// General Extension Method Helpers
///
/// No real organization, just Extension functions that make my life easier
///
/// Some things you'll find here.
/// Each one should have a bit of documentation explaining more.
///
/// Extensions to String
///   - chartAt()
///
/// Extensions to ui.Image
///   - getBounds()
///   - drawRotateSquare
///
/// Extensions to double
///   - fraction()
///
/// General Extensions
///   - Map()
///
/// Extensions to ClockModel
///   - get weatherEmoji
///
/// Extensions to TextStyle
///   - withNovaMono()

///📝📝📝📝📝📝📝📝📝📝
/// String Helpers
///
/// Things I use on strings to help coding
///
extension StringHelpers on String {
  String charAt(int idx) => this.substring(idx, idx + 1);
}

///🖼️🖼️🖼️🖼️🖼️🖼️🖼️🖼️🖼️🖼️
/// Image Helpers
/// Extending ui.Image to make it easier to draw to the screen
final kTargetRect = Rect.fromCenter(center: Offset.zero, width: 1, height: 1);

extension ImageHelpers on ui.Image {
  // Draws a Square Image rotated at offset around it's axis
  void drawRotatedSquare(
      {Canvas canvas,
      double size,
      Offset offset,
      double rotation,
      Paint paint,
      bool flip = false}) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    if (flip) {
      canvas.scale(-1, 1);
    }

    canvas.save();
    canvas.rotate(flip ? -rotation : rotation);
    canvas.scale(size);
    canvas.drawImageRect(this, bounds(), kTargetRect, paint);
    canvas.restore();
    canvas.restore();
  }

  Rect bounds() =>
      Rect.fromLTRB(0, 0, this.width.toDouble(), this.height.toDouble());
}

///🧮🧮🧮🧮🧮🧮🧮🧮🧮🧮
/// Math Helpers
///
extension DoubleHelpers on double {
  ///
  /// Gets the fraction of a double, e.g. (1.234) => 0.234
  ///
  double fraction() => this - this.floorToDouble();
}

///🗺️🗺️🗺️🗺️🗺️🗺️🗺️🗺️🗺️🗺️
/// Global .chain((in)=>out)
///
/// I = Input Type
/// O = output Type
///
/// Usage:
///  "test"
///    .chain((val)=>val.length)      -> 4
///    .chain((val)=>val*val)         -> 16
///
/// Just like you'd map in a collection
///
/// Useful for scoping a value without
/// creating a variable.

extension ChainHelper<IN, OUT> on IN {  
  OUT chain<OUT>(OUT mapFunc(IN input)) => mapFunc(this);
}

///📏📏📏📏📏📏📏📏📏📏
/// Helpers for the Vector3 class
extension VectorHelpers on vector.Vector3 {
  //Collapse a vector to a offset
  Offset toOffset() => Offset(this.x, this.y);
}

///🕓🕓🕓🕓🕓🕓🕓🕓🕓
/// Helpers for the ClockModel
///

//Map of Weather to Emoji
const weatherMap = {
  WeatherCondition.cloudy: '☁️',
  WeatherCondition.foggy: '🌫️',
  WeatherCondition.rainy: '🌧️',
  WeatherCondition.snowy: '🌨️',
  WeatherCondition.sunny: '☀️',
  WeatherCondition.thunderstorm: '⛈️',
  WeatherCondition.windy: '🌬️'
};


extension ClockModelHelpers on ClockModel {
  // Want to show the weather as a Emoji
  String get weatherEmoji => weatherMap[this.weatherCondition];
}

extension TextStyleHelpers on TextStyle {
  TextStyle withNovaMono() => this.copyWith(fontFamily: "NovaMono", fontWeight: FontWeight.bold);
}


