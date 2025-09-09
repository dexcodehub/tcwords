# KidWord Adventure - Resource Requirements

This document describes the resources needed for the KidWord Adventure app.

## Images

The following images are needed in the `assets/images/` directory:

1. Animal images:
   - dog.png
   - cat.png
   - elephant.png
   - lion.png
   - monkey.png
   - bird.png
   - fish.png

2. Vehicle images:
   - car.png
   - truck.png
   - bus.png
   - bike.png
   - train.png

3. Playground equipment images:
   - slide.png
   - swing.png
   - seesaw.png

4. Color images:
   - red.png
   - blue.png
   - green.png
   - yellow.png
   - orange.png

5. Number images:
   - one.png
   - two.png
   - three.png
   - four.png
   - five.png

6. Food images:
   - apple.png
   - banana.png
   - bread.png
   - milk.png
   - egg.png

7. Body part images:
   - head.png
   - hand.png
   - foot.png
   - eye.png
   - nose.png

8. Toy images:
   - ball.png
   - doll.png
   - toy_car.png
   - blocks.png
   - teddy_bear.png

9. Game icon images:
   - matching_game.png
   - puzzle_game.png
   - category_game.png

All images should be in PNG format with transparent backgrounds where appropriate. Recommended size is 200x200 pixels.

## Audio Files

The following audio files are needed in the `assets/audios/` directory:

Each word should have a corresponding audio file in MP3 format:
- car.mp3
- truck.mp3
- bus.mp3
- bike.mp3
- train.mp3
- slide.mp3
- swing.mp3
- seesaw.mp3
- dog.mp3
- cat.mp3
- elephant.mp3
- lion.mp3
- monkey.mp3
- bird.mp3
- fish.mp3
- red.mp3
- blue.mp3
- green.mp3
- yellow.mp3
- orange.mp3
- one.mp3
- two.mp3
- three.mp3
- four.mp3
- five.mp3
- apple.mp3
- banana.mp3
- bread.mp3
- milk.mp3
- egg.mp3
- head.mp3
- hand.mp3
- foot.mp3
- eye.mp3
- nose.mp3
- ball.mp3
- doll.mp3
- toy_car.mp3
- blocks.mp3
- teddy_bear.mp3

Audio files should be clear pronunciations of the words, approximately 1-2 seconds each.

## Adding Resources

To add resources to the app:

1. Create the image and audio files as described above
2. Place them in the appropriate directories:
   - Images: `assets/images/`
   - Audio: `assets/audios/`
3. Run `flutter pub get` to update dependencies
4. Run `flutter pub run build_runner build` if needed
5. Test the app to ensure all resources load correctly