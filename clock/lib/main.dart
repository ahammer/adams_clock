import 'package:adams_clock/digital_clock.dart';
import 'package:adams_clock/space_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  runApp(ClockCustomizer((model) => Stack(
        children: <Widget>[
          ClockScene(model: model),
          Align(
              alignment: Alignment.bottomRight, child: TextClock(model: model))
        ],
      )));
}
