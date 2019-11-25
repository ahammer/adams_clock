import 'dart:async';

import 'package:adams_clock/clocks/ticker.dart';
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
final DateFormat timeFormat = DateFormat("HH:mm:ss");
final DateFormat dateFormat = DateFormat.yMd();

class LocationWidget extends StatelessWidget {
  final ClockModel model;

  const LocationWidget({Key key, @required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  style:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 10)),
              
            ],
          ),
        ),
      ),
    );
  }
}


class DateWidget extends StatelessWidget {
  const DateWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TickerWidget(
      builder: () => dateFormat.format(DateTime.now()).replaceRange(6, 8, ""),
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

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TickerWidget(
      builder: () => timeFormat.format(DateTime.now()),
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
