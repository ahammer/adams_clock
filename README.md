# Adams Space Clock

This is my clock. The Planets indicate the rough positions of the "hands" of a clock would point. The moon rotates relative to the center of the earth. All planets will be "up" at 12:00:00am and "down" at 12:30:30pm. There should be hourly eclipses in Dark mode.

Best on Desktop or Mobile

| Light | Dark |
| ----- | ---- |
| 12:00:00 |
| ![12:00:00 Dark](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/dark000000.png) | ![12:00:00 Light](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/light000000.png) |
| 3:15:15 |
| ![03:15:15 Dark](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/dark031515.png) | ![3:15:15 Light](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/light031515.png) |
| 6:30:30 |
| ![6:30:30 Dark](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/dark063030.png) | ![6:30:30 Light](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/light063030.png) |
| 9:45:45 |
| ![9:45:45 Dark](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/dark094545.png) | ![9:45:45 Light](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/light094545.png) |
| ![Adams Clock](https://raw.githubusercontent.com/ahammer/adams_clock/master/screenshots/preview.webp) |





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
