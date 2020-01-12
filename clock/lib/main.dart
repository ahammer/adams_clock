import 'package:flutter_clock_helper/model.dart';
import 'package:intl/intl.dart';
import 'package:adams_clock/clocks/space_clock.dart';
import 'package:adams_clock/clocks/ticker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/customizer.dart';
import 'package:adams_clock/util/extensions.dart';
import 'package:adams_clock/util/string_util.dart';


// Use this time instead of DateTime.now() to globally inject a specific time
DateTime get spaceClockTime => DateTime.now();
// Use this if you want to test a particular time
//DateTime get spaceClockTime => DateTime.utc(2000,1,1,0,0,0);
//DateTime get spaceClockTime => DateTime.utc(2000,1,1,3,15,15);
//DateTime get spaceClockTime => DateTime.utc(2000,1,1,6,30,30);
//DateTime get spaceClockTime => DateTime.utc(2000,1,1,9,45,45);
// Or just want to see it really fast
//DateTime get spaceClockTime => DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch * 60*60);


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
    () => _timeFormat24.format(spaceClockTime);
final StringBuilder buildTime12String =
    () => _timeFormat12.format(spaceClockTime);
final StringBuilder buildDateString = () => _dateFormat.format(spaceClockTime);

String buildTickerText(ClockModel model) {
  final phase = (spaceClockTime.second / 5).round() % 5;

  String currentPart;
  if (phase == 0) {
    currentPart = "NOW ${model.temperatureString}";
  } else if (phase == 1) {
    currentPart = "LOW ${model.lowString}";
  } else if (phase == 2) {
    currentPart = "HIGH ${model.highString}";
  } else if (phase == 3) {
    currentPart = model.location;
  } else {
    currentPart = buildDateString();
  }

  return "$currentPart";
}

class AdamsSpaceClock extends StatelessWidget {
  final ClockModel model;
  const AdamsSpaceClock({Key key, @required this.model}) : super(key: key);

  String buildTickerString() {
    String timeString =
        model.is24HourFormat ? buildTime24String() : buildTime12String();
    return buildSpacedString(" $timeString ", "${buildTickerText(model)}  ", 36);
  }

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
              child: StyledTicker(builder: buildTickerString, clockModel: model),
            )),
      ],
    );
  }
}
