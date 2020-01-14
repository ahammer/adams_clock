import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';

// For building the current string to display
typedef String StringBuilder();

// For building a widget for a individual character in the string
typedef Widget BuildDigitWidget(String value, bool first, bool last);

///
/// Ticker Widget
///
/// It breaks a String up into it's characters, and displays
/// each character in it's own AnimatedSwitcher, so we can animate as
/// characters change
///
/// BuildDigitWidget => Builds the widget to display a character
/// StringBuilder => Builds the string we want to display
///
/// It updates every 1 seconds
///
/// There is some randomness built into transition time
/// Because it looks cool
///
class TickerWidget extends StatefulWidget {
  final BuildDigitWidget digitBuilder;
  final StringBuilder builder;
  final int tickerRandomnessMs;
  final int tickerBaseTimeMs;

  TickerWidget(
      {this.builder,
      this.digitBuilder,
      this.tickerRandomnessMs = 500,
      this.tickerBaseTimeMs = 200});

  @override
  _TickerWidgetState createState() => _TickerWidgetState();
}

///
/// Handles the rebuilding of this widget
///
/// It'll rebuild once a second.
///
class _TickerWidgetState extends State<TickerWidget> {
  Timer _timer;

  //100 randoms we can use to offset the Ticker timings
  final List<double> _random =
      List.generate(100, (idx) => Random.secure().nextDouble());

  @override
  void initState() {
    //Each ticker should run once a second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      //Trigger a rebuild
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  ///  Build the Widget for the Ticker
  ///
  ///  1) Get the current string to show
  ///  2) Build a row full of _TickerCharacterViews
  ///  3) Return that row.
  @override
  Widget build(BuildContext context) =>
      widget.builder().chain((currentString) => Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ...List.generate(
                  currentString.length,
                  (idx) => _TickerCharacterView(
                      duration: Duration(
                          milliseconds: widget.tickerBaseTimeMs +
                              (_random[idx % _random.length] *
                                      widget.tickerRandomnessMs)
                                  .toInt()),
                      first: idx == 0,
                      last: idx == (currentString.length - 1),
                      builder: widget.digitBuilder,
                      digit: currentString.charAt(idx)))
            ],
          ));
}

/// Ticker Character View
///
///
class _TickerCharacterView extends StatelessWidget {
  final String digit;
  final bool first, last;
  final BuildDigitWidget builder;
  final Duration duration;

  const _TickerCharacterView(
      {Key key,
      @required this.digit,
      @required this.builder,
      @required this.first,
      @required this.last,
      this.duration = const Duration(milliseconds: 500)})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          AnimatedSwitcher(
              transitionBuilder: (child, animation) =>
                  _TickerCharacterTransition(
                      child: child,
                      scale: animation,
                      alignment: Alignment.center),
              child: builder(digit, first, last),
              duration: duration),
        ],
      );
}

///
/// Derived from ScaleTransition
///
/// Changed the X scale to be fixed at 1.
class _TickerCharacterTransition extends AnimatedWidget {
  const _TickerCharacterTransition({
    Key key,
    @required this.scale,
    this.alignment = Alignment.center,
    this.child,
  })  : assert(scale != null),
        super(key: key, listenable: scale);


  final Animation<double> scale;

  final Alignment alignment;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      (Matrix4.identity()..scale(1.0, scale.value, 1.0))
          .chain((transform) => Transform(
                transform: transform,
                alignment: alignment,
                child: child,
              ));
}
