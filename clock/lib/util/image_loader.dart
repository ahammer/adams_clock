import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'extensions.dart';

///
/// Loads an image from an asset
///
Future<ui.Image> loadImageFromAsset(String asset) async {
  /// Read the bytes of the Data into a list
  final img = (await rootBundle.load('assets/$asset.png'))
      .chain((bytes) => Uint8List.view(bytes.buffer));

  final Completer<ui.Image> completer = Completer();

  // Decode the Image in a Future Envelope
  ui.decodeImageFromList(img, (ui.Image img) {
    return completer.complete(img);
  });

  // Return the future
  return completer.future;
}
