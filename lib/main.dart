import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(GameWidget(
      game: MyGame(),
      initialActiveOverlays: [],
    ));

class MyGame extends FlameGame with TapDetector {
  SpriteComponent background = SpriteComponent();
  SpriteComponent deadPlane = SpriteComponent();
  SpriteAnimationComponent flyingPlane = SpriteAnimationComponent();

  bool gameOver = false;
  final double idleWidth = 80.0;
  final double idleHeight = 100.0;

  late AudioPool pool;

  @override
  Future onLoad() async {
    double deviceWidth = size[0];
    double deviceHeight = size[1];

    pool = await AudioPool.create('flying.mp3');

    ParallaxComponent movingBackground = await ParallaxComponent.load(
        [ParallaxImageData('BG.png'), ParallaxImageData('BG.png')],
        repeat: ImageRepeat.repeatX,
        baseVelocity: Vector2(100, 0),
        velocityMultiplierDelta: Vector2(2, 0));
    add(movingBackground);

/*    background
      ..sprite = await loadSprite('BG.png')
      ..size = Vector2(deviceWidth * 1, deviceHeight * 1);
    add(background);*/

    deadPlane
      ..sprite = await loadSprite('dead.png')
      ..size = Vector2(idleWidth + 22, idleHeight - 20)
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(deviceWidth / 2, size[1] + 10);

    final airplane = await fromJSONAtlas('plane.png', 'plane.json');
    SpriteAnimation flying =
        SpriteAnimation.spriteList(airplane, stepTime: 0.1);

    flyingPlane
      ..animation = flying
      ..anchor = Anchor.bottomCenter
      ..position = Vector2(deviceWidth / 2, deviceHeight / 2)
      ..size = Vector2(100, 80);
    add(flyingPlane);

    super.onLoad();
  }

  double speedY = 0.0;
  final gravity = 1200;

  @override
  void update(double dt) {
    super.update(dt);

/*    background.x = background.x - dt * 130;
    if ((background.x).abs() > size[0]) {
      background.x = 0;
    }*/

    speedY += dt * gravity;
    flyingPlane.y += (speedY * dt) / 2;

    if (flyingPlane.y > size[1] + 10) {
      gameOver = true;
    }

    if (gameOver) {
      remove(flyingPlane);
      add(deadPlane);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownInfo info) {
    speedY = -500.0;
    pool.start(volume: 0.5);
    super.onTapDown(info);
  }
}
