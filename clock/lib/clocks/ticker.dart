import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:adams_clock/util/extensions.dart';
import 'package:flutter_clock_helper/model.dart';

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
}

///
/// Handles the rebuilding of this widget
///
/// It'll rebuild once a second.
///
class _TickerWidgetState extends State<TickerWidget> {
  Timer _timer;

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

  const _TickerCharacterView(
      {Key key,
      @required this.digit,
      @required this.builder,
      @required this.first,
      @required this.last})
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
              duration: Duration(milliseconds: 500)),
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
    @required Animation<double> scale,
    this.alignment = Alignment.center,
    this.child,
  })  : assert(scale != null),
        super(key: key, listenable: scale);

  Animation<double> get scale => listenable;

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

///
/// This is the ready-to-use ticker I use by default across all 4 corners
///
class StyledTicker extends StatelessWidget {
  final StringBuilder builder;
  final ClockModel clockModel;
  final double height;
  final double fontSize;

  const StyledTicker(
      {Key key,
      @required this.builder,
      this.height = 20,
      this.fontSize = 12,
      @required this.clockModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).canvasColor.withOpacity(0.75),
                  blurRadius: 2,
                  spreadRadius: 2)
            ],
            borderRadius: BorderRadius.circular(this.height / 2),
            color: Colors.transparent),
        height: height,
        child: ClipRect(
          child: TickerWidget(
            builder: builder,
            digitBuilder: (glyph, first, last) => Container(
                key: ValueKey(glyph),
                child: Center(
                    child: (last)
                        ? Container(
                          decoration: BoxDecoration(
                            
                            image: DecorationImage(image: ExactAssetImage(clockModel.weatherEmoji), fit: BoxFit.contain)
                          ),
                          width:height,
                          height:height,
                          )
                        : Text(
                            glyph,
                            style: Theme.of(context)
                                .textTheme
                                .subhead
                                .withNovaMono()
                                .copyWith(fontSize: fontSize),
                          ))),
          ),
        ),
      );
}
