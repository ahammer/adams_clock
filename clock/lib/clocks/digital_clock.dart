import 'package:adams_clock/util/ticker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:adams_clock/util/extensions.dart';
import 'package:intl/intl.dart';

///
/// This is the Widget-Based, Themed, Clock display
///
/// It shows actual easy to read information
///
final DateFormat _timeFormat = DateFormat("HH:mm:ss");
final DateFormat _dateFormat = DateFormat.yMd();

///
/// LocationWidget
///
/// Shows the City/Temp/Min/Max and Current Weather
///
class LocationWidget extends StatelessWidget {
  final ClockModel model;

  const LocationWidget({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(model.location,
                    style: Theme.of(context).textTheme.subhead.copyWith(
                        fontWeight: FontWeight.bold, shadows: [Shadow()])),
                Text("${model.temperatureString} ${model.weatherEmoji}",
                    style: Theme.of(context).textTheme.subhead),
                Text("${model.lowString} - ${model.highString}",
                    style: Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
      );
}

///
/// Date Widget
///
/// A Ticker Widget for the Date in MM/DD/YYY format
///
class DateWidget extends StatelessWidget {
  const DateWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TickerWidget(
      builder: () => _dateFormat.format(DateTime.now()).replaceRange(6, 8, ""),
      digitBuilder: (glyph) => Material(
          elevation: 2,
          key: ValueKey(glyph),
          child: Container(
              width: 16,
              child: Center(
                  child: Text(
                glyph,
                style: theme.textTheme.subhead.copyWith(fontFamily: "Glegoo"),
              )))),
    );
  }
}

///
/// Time Widget
///
/// A Ticker widget for the time in HH:MM:SS format
///
class TimeWidget extends StatelessWidget {
  const TimeWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TickerWidget(
      builder: () => _timeFormat.format(DateTime.now()),
      digitBuilder: (glyph) => Material(
          elevation: 2,
          key: ValueKey(glyph),
          child: Container(
              width: 16,
              child: Center(
                  child: Text(
                glyph,
                style: theme.textTheme.subhead.copyWith(
                    fontWeight: FontWeight.bold, fontFamily: "Glegoo"),
              )))),
    );
  }
}
