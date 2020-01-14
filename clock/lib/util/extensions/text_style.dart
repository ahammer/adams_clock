import 'package:flutter/material.dart';

extension TextStyleHelpers on TextStyle {
  TextStyle withNovaMono() =>
      this.copyWith(fontFamily: "NovaMono", fontWeight: FontWeight.bold);
}
