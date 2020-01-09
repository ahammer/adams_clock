import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:adams_clock/clocks/space_clock.dart';
import 'package:adams_clock/clocks/ticker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:adams_clock/util/extensions.dart';

void main() {
  ///
  ///  For windows dev
  ///
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(ClockCustomizer((model) => AdamsSpaceClock(model: model)));
}

final DateFormat _timeFormat24 = DateFormat("HH:mm:ss");
final DateFormat _timeFormat12 = DateFormat("hh:mm:ss");
final DateFormat _dateFormat = DateFormat.yMd();

final StringBuilder buildTime24String =
    () => _timeFormat24.format(DateTime.now());
final StringBuilder buildTime12String =
    () => _timeFormat12.format(DateTime.now());
final StringBuilder buildDateString = () => _dateFormat.format(DateTime.now());

String buildWeatherTickerText(ClockModel model) {
  final phase = (DateTime.now().second / 5).round() % 3;

  String currentPart;
  if (phase == 0) {
    currentPart = "NOW ${model.temperatureString}";
  } else if (phase == 1) {
    currentPart = "LOW ${model.lowString}";
  } else if (phase == 2) {
    currentPart = "HIGH ${model.highString}";
  }

  String buffer = "           ";
  String output = "$currentPart";

  return model.weatherEmoji +
      buffer.replaceRange(buffer.length - output.length, buffer.length, output);
}

class AdamsSpaceClock extends StatelessWidget {
  final ClockModel model;
  const AdamsSpaceClock({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        //The space clock
        SpaceClockScene(),

/*
        
        // The Time widget
        Align(
            alignment: Alignment.topRight,
            child: StyledTicker(
                fontSize: 14,
                height: 24,
                builder: () => buildWeatherTickerText(model))),

        // The Location
        Align(
            alignment: Alignment.topLeft,
            child: StyledTicker(
                fontSize: 14, height: 24, builder: () => model.location)),
*/
        // The Time widget
        Align(
            alignment: Alignment.bottomCenter,
            child: StyledTicker(
                builder: model.is24HourFormat
                    ? buildTime24String
                    : buildTime12String)),
/*
        // The Date Widget
        Align(
            alignment: Alignment.bottomLeft,
            child: StyledTicker(builder: buildDateString))*/
            
      ],
    );
  }
}
