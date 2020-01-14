# adams_clock

This is my clock. The Planets indicate the rough positions of the "hands" of a clock would point. The moon rotates relative to the center of the earth. All planets will be "up" at 12:00:00am and "down" at 12:30:30pm.

Best on Desktop or Mobile

Not supported on Web (It doesn't work with everything I use, e.g. drawPoints() for the stars, blending bitmaps, transparent pngs). It'll just render the background and the digital clock portion.

- Tech Overview

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


Notes
- Supported Platforms (Android, iOS, Desktop) 
- Web will barely run, but expect most of it to be broken, I suspect canvas in web support is not fully there yet. Maybe it'll improve with future releases of flutter.
- http://www.adamhammer.ca/minesweep/ => If you really want a flutter web demo to play with.