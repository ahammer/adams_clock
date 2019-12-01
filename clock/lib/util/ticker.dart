import 'dart:async';

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
                first: idx == 0,
                last: idx == (string.length - 1),
                builder: widget.digitBuilder,
                digit: string.charAt(idx)))
      ],
    );
  }
}

class _TickerCharacterView extends StatelessWidget {
  final String digit;
  final bool first, last;
  final BuildDigitWidget builder;

  const _TickerCharacterView(
      {Key key,
      @required this.digit,
      @required this.builder,
      @required this.first,
      @required this.last})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
            transitionBuilder: (child, animation) => _TickerCharacterTransition(
                child: child, scale: animation, alignment: Alignment.center),
            child: builder(digit, first, last),
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

///
/// This is the ready-to-use ticker I use by default across all 4 corners
///
class StyledTicker extends StatelessWidget {
  final StringBuilder builder;
  final double height;
  final double fontSize;

  const StyledTicker({Key key, @required this.builder, this.height = 32, this.fontSize = 18}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(2.0),
        child: Container(

          height: height,
          child: Opacity(
            opacity: 0.5,
            child: TickerWidget(
              builder: builder,
              digitBuilder: (glyph, first, last) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(1.0),
                    borderRadius: first
                        ? BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8))
                        : last
                            ? BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8))
                            : null,
                  ),
                  key: ValueKey(glyph),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Center(
                        child: Text(
                      glyph,
                      style:
                          Theme.of(context).textTheme.subhead.withNovaMono().copyWith(fontSize: fontSize),
                    )),
                  )),
            ),
          ),
        ),
      );
}
