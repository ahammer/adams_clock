import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

///
/// Loads an image from an asset
///
Future<ui.Image> loadImageFromAsset(String asset) async {
  final ByteData data = await rootBundle.load('assets/$asset.png');
  List<int> img = Uint8List.view(data.buffer);

  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(img, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}
