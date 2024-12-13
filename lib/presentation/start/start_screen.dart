import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ChinchiroGameScreen extends StatefulWidget {
  @override
  ChinchiroGameScreenState createState() => ChinchiroGameScreenState();
}

class ChinchiroGameScreenState extends State<ChinchiroGameScreen> {
  ValueNotifier<GameState> gameState = ValueNotifier(GameState.waiting);
  int currentPlayer = 1;
  int player1Score = 0;
  int player2Score = 0;
  List<int> diceValues = [1, 1, 1];
  double shakeMagnitude = 0;
  double shakeThreshold = 15; // しきい値を大きく
  DateTime? lastShakeTime;
  bool isShaking = false;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (gameState.value == GameState.playing) {
        double currentMagnitude =
            sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

        if (currentMagnitude > shakeThreshold) {
          if (lastShakeTime == null ||
              DateTime.now().difference(lastShakeTime!).inMilliseconds > 200) {
            lastShakeTime = DateTime.now();
            setState(() {
              isShaking = true;
              shakeMagnitude = currentMagnitude;
            });
          }
        } else if (isShaking) {
          isShaking = false;
          _rollDice();
        }
      }
    });
  }

  void _rollDice() {
    setState(() {
      diceValues = List.generate(3, (index) => Random().nextInt(6) + 1);
      int currentScore = diceValues.reduce((a, b) => a + b);
      if (currentPlayer == 1) {
        player1Score += currentScore;
      } else {
        player2Score += currentScore;
      }
      _checkGameResult();
      currentPlayer = 3 - currentPlayer; // プレイヤー交代
      gameState.value = GameState.waiting;
    });
  }

  void _checkGameResult() {
    if (player1Score >= 100 || player2Score >= 100) {
      gameState.value = GameState.result;
    }
  }

  void _resetGame() {
    setState(() {
      gameState.value = GameState.waiting;
      currentPlayer = 1;
      player1Score = 0;
      player2Score = 0;
      diceValues = [1, 1, 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('チンチロゲーム')),
      body: GestureDetector(
        // タップ検出用
        onTap: () {
          if (gameState.value == GameState.waiting) {
            setState(() {
              gameState.value = GameState.playing;
            });
          }
        },
        child: Center(
          child: ValueListenableBuilder<GameState>(
            valueListenable: gameState,
            builder: (context, state, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Player 1: $player1Score',
                      style: TextStyle(fontSize: 24)),
                  Text('Player 2: $player2Score',
                      style: TextStyle(fontSize: 24)),
                  Text('Current Turn: Player $currentPlayer',
                      style: TextStyle(fontSize: 20)),
                  if (state == GameState.waiting)
                    Text('Player $currentPlayer Ready?',
                        style: TextStyle(fontSize: 24)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diceValues
                        .map((value) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Dice(value: value),
                            ))
                        .toList(),
                  ),
                  if (state == GameState.result) ...[
                    Text(
                      player1Score > player2Score
                          ? 'Player 1 Wins!'
                          : player1Score < player2Score
                              ? 'Player 2 Wins!'
                              : 'Draw!',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: Text('Play Again'),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dice extends StatelessWidget {
  final int value;

  const Dice({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Center(
        child: Text(
          value.toString(),
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }
}

enum GameState { waiting, playing, result }
