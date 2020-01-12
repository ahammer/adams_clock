import 'package:adams_clock/clocks/space/space_clock.dart';
import 'package:adams_clock/clocks/ticker/ticker_clock.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';




void main() {
  ///
  ///  For windows dev
  ///
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(ClockCustomizer((model) => ClockScaffolding(model: model)));
}


class ClockScaffolding extends StatelessWidget {
  final ClockModel model;
  const ClockScaffolding({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //The space clock
        SpaceClockScene(model),

        Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: DateTimeAndWeatherTicker(clockModel: model),
            )),
      ],
    );
  }
}
