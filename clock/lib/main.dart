import 'package:adams_clock/clocks/digital_clock.dart';
import 'package:adams_clock/clocks/space_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';

void main() {
  ///
  ///  For windows dev
  ///
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(ClockCustomizer((model) => Stack(
        children: <Widget>[
          //The space clock
          SpaceClockScene(),

          // The Location/Temp widget
          Align(
              alignment: Alignment.topRight,
              child: LocationWidget(model: model)),

          // The Time widget
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Opacity(
                    opacity: 0.75,
                    child: Container(height: 32, child: TimeWidget(model: model,))),
              )),

          // The Date Widget
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Opacity(
                    opacity: 0.75,
                    child: Container(height: 32, child: DateWidget())),
              ))
        ],
      )));
}
