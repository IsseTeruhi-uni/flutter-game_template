import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ChinchiroGameScreen extends StatefulWidget {
  const ChinchiroGameScreen({super.key});

  @override
  ChinchiroGameScreenState createState() => ChinchiroGameScreenState();
}

class ChinchiroGameScreenState extends State<ChinchiroGameScreen> {
  late ChinchiroGame _game;

  @override
  void initState() {
    super.initState();
    _game = ChinchiroGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: _game),
    );
  }
}

class ChinchiroGame extends FlameGame {
  int dice1 = 1;
  int dice2 = 1;
  int dice3 = 1;
  final double shakeThreshold = 15.0;
  AccelerometerEvent? lastEvent;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _startAccelerometer();
    _addDiceSprites();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (lastEvent != null) {
        double dx = event.x - lastEvent!.x;
        double dy = event.y - lastEvent!.y;
        double dz = event.z - lastEvent!.z;

        double shakeMagnitude = sqrt(dx * dx + dy * dy + dz * dz);

        if (shakeMagnitude > shakeThreshold) {
          _rollDice();
        }
      }
      lastEvent = event;
    });
  }

  void _rollDice() {
    dice1 = Random().nextInt(6) + 1;
    dice2 = Random().nextInt(6) + 1;
    dice3 = Random().nextInt(6) + 1;
    _updateDiceSprites();
  }

  void _addDiceSprites() {
    add(DiceSprite(dice1, position: Vector2(size.x / 2 - 100, size.y / 2)));
    add(DiceSprite(dice2, position: Vector2(size.x / 2, size.y / 2)));
    add(DiceSprite(dice3, position: Vector2(size.x / 2 + 100, size.y / 2)));
  }

  void _updateDiceSprites() {
    children.whereType<DiceSprite>().toList().asMap().forEach((index, sprite) {
      sprite.value = [dice1, dice2, dice3][index];
    });
  }

  @override
  void onRemove() {
    _accelerometerSubscription.cancel();
    super.onRemove();
  }
}

class DiceSprite extends PositionComponent {
  int value;

  DiceSprite(this.value, {super.position}) : super(size: Vector2(50, 50));

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawRect(size.toRect(), paint);
    _drawDiceValue(canvas);
  }

  void _drawDiceValue(Canvas canvas) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '$value',
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2,
      ),
    );
  }
}
