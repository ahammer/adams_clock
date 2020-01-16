import 'package:flutter/services.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'clocks/ticker/ticker_clock.dart';

///
/// This is the Canvas free version of the clock
///
/// I wanted to give the web something, even if not a full experience.
void main() {
  //We have no inputs, so Fuschia should be fine all around
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(ClockCustomizer((model) => ClockScaffolding(model: model)));
}

///
/// The scaffolding of this clock
///
/// It's a Stack
/// Layer 1: The space scene
/// Layer 2: The DateTimeAndWeatherTicker the draws in the top left
///
class ClockScaffolding extends StatelessWidget {
  /// The ClockModel, needed by things to make decisions about what to draw
  final ClockModel model;

  /// Construct a clock scaffolding given a model
  const ClockScaffolding({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(children: [
        Container(
          color: Theme.of(context).colorScheme.primary,
          child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DateTimeAndWeatherTicker(
                  clockModel: model,
                  fontSize: 30,
                  height: 40,
                ),
              )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "🚧 This is not the full clock\n"
              "👉Only the Widget Based Ticker works.\n"
              "👉Canvas drawing not well supported on web.\n"
              "To see Space/Stars/Sun, run on 📱 or 🖥️",
              textAlign: TextAlign.left,
            ),
          ),
        )
      ]);
}
