# adams_clock

This is my clock. The Planets indicate the rough positions of the "hands" of a clock would point. The moon rotates relative to the center of the earth. All planets will be "up" at 12:00:00am and "down" at 12:30:30pm. There is eclipses 8 times a day (12:00:00am/pm), and close to 3:16, 6:32, 9:47, when things line up.



Best on Desktop or Mobile

Only very partial web support due to canvas support needing some work, run main_web to get the simplified "web" version of
the digital clock only.

Tech notes
- Some Canvas, Some Widget System
- No 3rd party libraries (pure flutter 1.12)
- All ClockModel data utilized
- Easily configurable
- Pedantic & Effective Dart linted
- Extension Function APIs for various things

Space Clock
- Draws as fast as possible
- Background is a Bitmap that rotates slowly (static stars at infinity)
- Stars are a simple particle system. An array of Stars are created in a [0..1] ranged 3d cube. Z tranforms with time, and repeats >1 => 0. They are projected and transformed to screen stace in steps based on their distance. Each step has increasing opacity and size. This is so we can have "fade in" on the stars, without an individual draw call for each star, allowing far more stars.
- Planets are drawn with Extensions to UI.Image that help place and rotate them, based on their calculated position.
- The sun is drawn in layers, with a solid base layer, and 3 layers of varying texture/blending to give it a Perlin Noise style effect.

Digital Clock
- Card drawn in the bottom right
- Includes Date/Time/Weather
- Weather Type gets Emojified
- Tickers are pseudo random for a cool effect

Notes
- Supported Platforms (Android, iOS, Desktop) 
- The subset that works on the web can be run from web_main.dart (it's missing a lot)
- Optimized on a HTC One (2013) device.