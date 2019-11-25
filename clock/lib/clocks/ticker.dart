import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';

// For building the current string to display
typedef String StringBuilder();

// For building a widget for a individual character in the string
typedef Widget BuildDigitWidget(String value);

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
class TickerWidget extends StatefulWidget {
  final BuildDigitWidget digitBuilder;
  final StringBuilder builder;

  TickerWidget({this.builder, this.digitBuilder});

  @override
  _TickerWidgetState createState() => _TickerWidgetState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<StringBuilder>.has('builder', builder));
  }
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

  @override
  Widget build(BuildContext context) {
    final string = widget.builder();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...List.generate(
            string.length,
            (idx) => _TickerCharacterView(
                builder: widget.digitBuilder, digit: string.charAt(idx)))
      ],
    );
  }
}


class _TickerCharacterView extends StatelessWidget {
  final String digit;
  final BuildDigitWidget builder;

  const _TickerCharacterView({Key key, @required this.digit, @required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            transitionBuilder: (child, animation) => _TickerCharacterTransition(
                child: child, scale: animation, alignment: Alignment.center),
            child: builder(digit),
            duration: Duration(milliseconds: 500)),
      ],
    );
  }
}

///
/// Derived from ScaleTransition
///
/// Changed the X scale to be fixed at 1.
class _TickerCharacterTransition extends AnimatedWidget {
  const _TickerCharacterTransition({
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
