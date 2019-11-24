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
final DateFormat format = DateFormat("HHmmss");
class TextClock extends StatelessWidget {
  final ClockModel model;

  const TextClock({Key key, @required this.model}) : super(key: key);

  
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
              Text(model.location, style: Theme.of(context).textTheme.subhead),
              Container(width: 4, height: 2),
              Text("${model.temperatureString} ${model.weatherEmoji}",
                  style: Theme.of(context).textTheme.subhead),
              Container(width: 4, height: 2),
              Text("${model.lowString} - ${model.highString}",
                  style:
                      Theme.of(context).textTheme.body1.copyWith(fontSize: 10)),
              Container(width: 4, height: 6),
              TickerWidget(()=> format.format(DateTime.now()))
            ],
          ),
        ),
      ),
    );
  }
}
