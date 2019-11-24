import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:adams_clock/util/extensions.dart';

///
/// This is the Widget-Based, Themed, Clock display
///
/// It shows actual easy to read information
///
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
              TimeWidget()
            ],
          ),
        ),
      ),
    );
  }
}

class TimeWidget extends StatefulWidget {
  TimeWidget();

  @override
  _TimeWidgetState createState() => _TimeWidgetState();
}

class _TimeWidgetState extends State<TimeWidget> {
  Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> digits = ["0", "0", "0", "0", "0", "0"];
    final time = DateTime.now();
    final hour = time.hour;
    final hourString = hour.toString();
    final minutesString = time.minute.toString();
    final secondsString = time.second.toString();

    if (hourString.length > 1) {
      digits[0] = hourString.substring(0, 1);
      digits[1] = hourString.substring(1, 2);
    } else {
      digits[0] = '0';
      digits[1] = hourString.substring(0, 1);
    }

    if (minutesString.length > 1) {
      digits[2] = minutesString.substring(0, 1);
      digits[3] = minutesString.substring(1, 2);
    } else {
      digits[2] = '0';
      digits[3] = minutesString.substring(0, 1);
    }

    if (secondsString.length > 1) {
      digits[4] = secondsString.substring(0, 1);
      digits[5] = secondsString.substring(1, 2);
    } else {
      digits[4] = '0';
      digits[5] = secondsString.substring(0, 1);
    }
 final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...getDigitArray(digits[0],digits[1],digits[2],digits[3],digits[4],digits[5],theme.colorScheme.primary, theme.colorScheme.onPrimary)
      ],
    );
  }
}


List<Widget> getDigitArray(String a, b, c, d, e, f, Color bgColor, Color textColor) => [
        DigitView(digit: a),
        DigitView(digit: b),
        Container(width: 4, height: 1),
        DigitView(digit: c),
        DigitView(digit: c),
        Container(width: 4, height: 1),
        DigitView(digit: d),
        DigitView(digit: e),

];

class DigitView extends StatefulWidget {
  final String digit;
  

  const DigitView({Key key, this.digit}) : super(key: key);

  @override
  _DigitViewState createState() => _DigitViewState();
}

class _DigitViewState extends State<DigitView> {
  int _changes = 0;
  String _evenValue = "";
  String _oddValue = "";

  bool get isEven => (_changes % 2 == 0);

  @override
  void initState() {
    super.initState();
    _evenValue = widget.digit;
  }

  @override
  Widget build(BuildContext context) {
    updateState();
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            transitionBuilder: (child, animation) => DigitTransition(
                child: child, scale: animation, alignment: Alignment.center),
            child: isEven
                ? Digit(key: ValueKey(_evenValue), digit: _evenValue)
                : Digit(key: ValueKey(_oddValue), digit: _oddValue),
            duration: Duration(milliseconds: 200)),
      ],
    );
  }

  void updateState() {
    if (isEven) {
      if (_evenValue != widget.digit) {
        _oddValue = widget.digit;
        _changes++;
      }
    } else {
      if (_oddValue != widget.digit) {
        _evenValue = widget.digit;
        _changes++;
      }
    }
  }
}

///
/// Derived from ScaleTransition
///
/// Changed the X scale to be fixed at 1.
class DigitTransition extends AnimatedWidget {
  const DigitTransition({
    Key key,
    @required Animation<double> scale,
    this.alignment = Alignment.center,
    this.child,
  })  : assert(scale != null),
        super(key: key, listenable: scale);

  Animation<double> get scale => listenable;

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double scaleValue = scale.value;
    final Matrix4 transform = Matrix4.identity()..scale(1.0, scaleValue, 1.0);
    return Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}

class Digit extends StatelessWidget {
  final String digit;
  const Digit({
    Key key,
    this.digit,
    this.widget,
  }) : super(key: key);

  final DigitView widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Material(
          elevation: 3,
          child: Container(
              width: 20,
              height: 20,
              color: Theme.of(context).colorScheme.secondary,
              child: Center(
                  child: Text(
                digit,
                style: Theme.of(context).textTheme.subhead.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondary),
              )))),
    );
  }
}
