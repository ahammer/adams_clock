import 'package:flutter/animation.dart';

// Builds a string of Length length
// $left_______$right
// Used in the ticker
String buildSpacedString(String left, String right, int length) {
  String output = left;
  for (int i=0;i<length-(left.length+right.length);i++) {
    output+=" ";
  }
  output+=right;
  return output;


  
}