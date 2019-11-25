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
          ClockScene(model: model),
          Align(
              alignment: Alignment.topRight,
              child: LocationWidget(model: model)),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Opacity(opacity:0.75, child: Container(height:32, child: TimeWidget())),
              )),
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Opacity(opacity:0.75, child: Container(height:32, child: DateWidget())),
              ))
        ],
      )));
}
