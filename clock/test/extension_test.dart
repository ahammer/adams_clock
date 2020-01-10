import 'package:flutter_test/flutter_test.dart';
import 'package:adams_clock/util/extensions.dart';
void main() {
  test("Test chain()", (){
    expect ("hello"
      .chain((string)=>string.length)
      .chain((len)=>len*len)
      , equals(25));
  });
}