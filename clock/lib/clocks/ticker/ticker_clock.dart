import 'package:adams_clock/config/time_proxy.dart';
import 'package:adams_clock/ui/ticker.dart';
import 'package:adams_clock/util/string_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:adams_clock/util/extensions.dart';
import 'package:intl/intl.dart';

///
/// Ticker Clock
///
/// This is the Widget System clock
/// It's a implementation of the Generic TickerWidget in the ui folder

/// Format for 12 and 24 hour and Date
final DateFormat _timeFormat24 = DateFormat("HH:mm:ss");
final DateFormat _timeFormat12 = DateFormat("hh:mm:ss");
final DateFormat _dateFormat = DateFormat.yMd();

/// Methods to
String get time24 => _timeFormat24.format(spaceClockTime);
String get time12 => _timeFormat12.format(spaceClockTime);
String get date => _dateFormat.format(spaceClockTime);

// Each phase shows different "text" on the right
// There is 0,1,2,3,4
// 0 = Temp Now
// 1 = Low Temp
// 2 = High Temp
// 3 = Current Location
// 4 = Date
// note: kDelayS * kPhases should equal 3,5,10,15,20,30,60 if it's to loop seemlessly once a minute
const int kDelayS = 4;
const int kPhases = 5;

/// buildRightTickerText
/// String is decided based on the rules above
String buildRightTickerText(ClockModel model) {
  final phase = (spaceClockTime.second / kDelayS).round() % kPhases;
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
    currentPart = date;
  }

  return "$currentPart";
}

// Builds the actual ticker string
// e.g. "15:30:45               Mountain View, CA  "
// The string format is as follows
// [A][B][C+D]
// A = Time, with 1 character padding for UI
// B = X spaces (36 - (a.length + b.length + d.length)
// C = Right/Phased String, Temp/Location/Date
// D = 2 Character padding on the right for Icon Space
// Icons were originally emoji, but imported assets for compat
String buildTickerString(ClockModel clockModel) =>
    (clockModel.is24HourFormat ? time24 : time12).chain((timeString) =>
        buildSpacedString(
            " $timeString ", "${buildRightTickerText(clockModel)}  ", 36));

/// DateTimeAndWeatherTicker
///
/// This is the Ticker as a whole for showing the text at the top left
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

  /// We wrap this ticket in a decoration (getTickerDecoration)
  /// The ticker expects a method to generate it's current string (buildTickerString(clockModel))
  /// It also expects a builder function to generate the characters
  /// 
  /// Normally we add TickerCharacterWidget which draws 1 character
  /// On the last item, we draw the WeatherIcon 
  /// (there should be blank spaces on the end of the string to make room for it)
  @override
  Widget build(BuildContext context) => Container(
        decoration: getTickerDecoration(context),
        height: height,
        child: TickerWidget(
          builder: () => buildTickerString(clockModel),
          digitBuilder: (glyph, first, last) => last
              ? TickerWeatherIcon(clockModel: clockModel, height: height)
              : TickerCharacterWidget(
                  fontSize: fontSize,
                  glyph: glyph),
        ),
      );

  // Builds the decoration for the top-left Ticker
  // I use the Shadow as a background, to give a soft bordered round background
  BoxDecoration getTickerDecoration(BuildContext context) => BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).canvasColor.withOpacity(0.75),
              blurRadius: 2,
              spreadRadius: 2)
        ],
        borderRadius: BorderRadius.circular(this.height / 2),
        color: Colors.transparent);
}

/// TickerWeatherIcon
///
/// Handles the drawing of the weather icon
/// Uses ClockModel to get the weather
/// Size is HxH
/// 
class TickerWeatherIcon extends StatelessWidget {
  const TickerWeatherIcon({
    Key key,
    @required this.clockModel,
    @required this.height,
  }) : super(key: key);

  //We get the weather from the ClockModel
  final ClockModel clockModel;

  // We make this icon HxH in size
  final double height;

  @override
  Widget build(BuildContext context) => Container(        
        decoration: BoxDecoration(          
            image: DecorationImage(
                image: ExactAssetImage(clockModel.weatherAsset),
                fit: BoxFit.contain)),
        width: height,
        height: height,
      );
}

///
/// This builds a single character for the ticker
class TickerCharacterWidget extends StatelessWidget {
  const TickerCharacterWidget({
    Key key,
    @required this.glyph,
    @required this.fontSize,
  }) : super(key: key);

  final String glyph;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
        key: ValueKey(glyph),
        child: Center(
            child: Text(
          glyph,
          style: Theme.of(context)
              .textTheme
              .subhead
              .withNovaMono()
              .copyWith(fontSize: fontSize),
        )));
}
