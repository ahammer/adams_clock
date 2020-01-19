import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'clocks/space/space_clock.dart';
import 'clocks/ticker/ticker_clock.dart';

void main() {
  //We have no inputs, so Fuschia should be fine all around
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const MainWidget());
}

///
/// We broke out the "Main" widget into it's own
///
/// So we can "Navigate" to it
class MainWidget extends StatelessWidget {
  /// Main Screen
  const MainWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ClockCustomizer(
      (model) => Builder(builder: (context) => ClockScaffolding(model: model)));
}

///
/// The scaffolding of this clock
///
/// It's a Stack
/// Layer 1: The space scene
/// Layer 2: The DateTimeAndWeatherTicker the draws in the top left
///
class ClockScaffolding extends StatelessWidget {
  /// Construct a clock scaffolding given a model
  const ClockScaffolding({@required this.model, Key key}) : super(key: key);

  /// The ClockModel, needed by things to make decisions about what to draw
  final ClockModel model;


  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          //The space clock
          SpaceClockScene(model),

          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: DateTimeAndWeatherTicker(clockModel: model),
              )),
        ],
      );
}
