import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef String StringBuilder();
class TickerWidget extends StatefulWidget {
  TickerWidget(this.builder);
  final StringBuilder builder;

  
  @override
  _TickerWidgetState createState() => _TickerWidgetState();
}

class _TickerWidgetState extends State<TickerWidget> {
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

  final DateFormat format = DateFormat("HHmmss");
  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[        
        ...getDigitArray(widget.builder(), theme.colorScheme.primary, theme.colorScheme.onPrimary)
      ],
    );
  }
}


List<Widget> getDigitArray(
        String digits, Color bgColor, Color textColor) =>
    [

      DigitView(digit: digits.substring(0,1)),
      DigitView(digit: digits.substring(1,2)),
      Container(width: 4, height: 1),
      DigitView(digit: digits.substring(2,3)),
      DigitView(digit: digits.substring(3,4)),
      Container(width: 4, height: 1),
      DigitView(digit: digits.substring(4,5)),
      DigitView(digit: digits.substring(5,6)),
    ];

class DigitView extends StatelessWidget {
  final String digit;

  const DigitView({Key key, this.digit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            transitionBuilder: (child, animation) => DigitTransition(
                child: child, scale: animation, alignment: Alignment.center),
            child: Digit(key: ValueKey(digit), digit: digit),                
            duration: Duration(milliseconds: 200)),
      ],
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
