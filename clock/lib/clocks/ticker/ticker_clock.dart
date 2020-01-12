import 'package:adams_clock/clocks/ticker.dart';
import 'package:adams_clock/util/string_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:adams_clock/util/extensions.dart';
import 'package:intl/intl.dart';
import 'package:adams_clock/time_proxy.dart';

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


///
/// This is the ready-to-use ticker I use by default across all 4 corners
///
class DateTimeAndWeatherTicker extends StatelessWidget {
  final ClockModel clockModel;
  final double height;
  final double fontSize;

  const DateTimeAndWeatherTicker(
      {Key key,
      this.height = 20,
      this.fontSize = 12,
      @required this.clockModel})
      : super(key: key);


  String buildTickerString() {
    String timeString =
        clockModel.is24HourFormat ? buildTime24String() : buildTime12String();
    return buildSpacedString(" $timeString ", "${buildTickerText(clockModel)}  ", 36);
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).canvasColor.withOpacity(0.75),
                  blurRadius: 2,
                  spreadRadius: 2)
            ],
            borderRadius: BorderRadius.circular(this.height / 2),
            color: Colors.transparent),
        height: height,
        child: ClipRect(
          child: TickerWidget(
            builder: buildTickerString,
            digitBuilder: (glyph, first, last) => Container(
                key: ValueKey(glyph),
                child: Center(
                    child: (last)
                        ? Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: ExactAssetImage(
                                        clockModel.weatherEmoji),
                                    fit: BoxFit.contain)),
                            width: height,
                            height: height,
                          )
                        : Text(
                            glyph,
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .withNovaMono()
                                .copyWith(fontSize: fontSize),
                          ))),
          ),
        ),
      );
}
