# Adam's Space Clock
Flutter Clock

A clock for the flutter clock challenge featuring the following

- A not physically accurate space simulation
- Sun, Earth and Moon, Starfield and Background
- A digital clock in the top-left so you can actually tell the time.
- "Dark" and "Light" themes. The sun is much bigger in the Light Theme.


Check it out on youtube (gif @ 16x speed)
[![Clock in action](https://raw.githubusercontent.com/ahammer/adams_clock/master/clock/screenshots/gif_preview.gif)](http://www.youtube.com/watch?v=pEJCsp5tsR4 "Clock in action")

Check the screenshot for reference times/examples, or the youtube link below. 
![alt text](https://raw.githubusercontent.com/ahammer/adams_clock/master/clock/screenshots/contact_sheet.jpg)


How it works

- Sun = Hour hand
- Earth = Minute Hand
- Moon = Seconds hand
- Sun and Earth rotate the screen. 
- Moon rotates the earth.


Drawn in the following order

- In a CustomPaint layer
  - Background image created digitally
    - drawn rotating slowly on the screen over time
  - StarField
    - Fixed pool of random stars [x,y,z] between [0 to 1]
    - z changes linearly through time
    - decimal is chopped off (e.g. 4.35 = 0.35). This keep's 0-1 range and represents "looping"
    - Transformed and projected with vector math
    - Batched and Drawn to reduce draw calls
 
  - Sun created from layers
    - Layer 0: Radial Gradient, White with soft border that fade towards deep orange.
    - Layer 1-6: Images blended with plus and multiply (defined in config)
    - Perlin Noise effect by blending layers give sun a dynamic feel
  - Earth and Moon
    - Bitmaps for the Moon/Earth
    - "Shadow" layer drawn on top.
    - Draw order between moon/earth is switched to simulate an orbit
- With the Widget System
  - Digital Clock    
    - Breaks down string every 1s
    - Updates individual characters with animated switcher as they change
  
