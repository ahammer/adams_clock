import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';

typedef String StringBuilder();

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
            (idx) => DigitView(
                builder: widget.digitBuilder, digit: string.charAt(idx)))
      ],
    );
  }
}

typedef Widget BuildDigitWidget(String value);

class DigitView extends StatelessWidget {
  final String digit;
  final BuildDigitWidget builder;

  const DigitView({Key key, @required this.digit, @required this.builder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            transitionBuilder: (child, animation) => DigitTransition(
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
