import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ChinchiroGameScreen extends StatefulWidget {
  const ChinchiroGameScreen({super.key});

  @override
  ChinchiroGameScreenState createState() => ChinchiroGameScreenState();
}

class ChinchiroGameScreenState extends State<ChinchiroGameScreen>
    with TickerProviderStateMixin {
  int currentPlayer = 1;
  List<int> playerScores = [0, 0];
  List<int> currentDiceValues = [1, 1, 1];
  String gameMessage = "Player 1's Turn: Press Ready to Start!";
  bool isShaking = false;
  bool isReady = false; // Readyボタンが押されたかどうか
  bool isRolling = false; // サイコロが振られているかどうか
  Timer? shakeTimer;

  late AnimationController _diceRotationController1;
  late AnimationController _diceRotationController2;
  late AnimationController _diceRotationController3;

  @override
  void initState() {
    super.initState();
    _diceRotationController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _diceRotationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _diceRotationController3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((AccelerometerEvent event) {
      if (!isReady) return; // Readyボタンが押されていない場合は振動を無視

      double currentMagnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (currentMagnitude > 15.0) {
        _handleShake();
      } else if (isShaking) {
        _handleShakeStop();
      }
    });
  }

  void _handleShake() {
    if (!isShaking && !isRolling) {
      // Add check for isRolling
      setState(() {
        isShaking = true;
        isRolling = true; // Set isRolling to true when the dice roll starts
      });
    }
    _rollDice();

    // 各サイコロに対して回転アニメーションを開始
    _diceRotationController1.forward(from: 0.0);
    _diceRotationController2.forward(from: 0.0);
    _diceRotationController3.forward(from: 0.0);

    // タイマーをリセット
    shakeTimer?.cancel();
    shakeTimer = Timer(const Duration(seconds: 1), () {
      if (isShaking) {
        setState(() {
          isShaking = false;
        });
        _endTurn();
      }
    });
  }

  void _handleShakeStop() {
    if (shakeTimer == null || !shakeTimer!.isActive) {
      shakeTimer = Timer(const Duration(seconds: 1), () {
        if (isShaking && isRolling) {
          // Ensure turn ends only if it's a valid roll
          setState(() {
            isShaking = false;
          });
          _endTurn();
        }
      });
    }
  }

  void _rollDice() {
    setState(() {
      currentDiceValues = List.generate(3, (index) => Random().nextInt(6) + 1);
    });
  }

  void _endTurn() {
    int score = _calculateScore(currentDiceValues);
    playerScores[currentPlayer - 1] = score;

    if (currentPlayer == 1) {
      setState(() {
        currentPlayer = 2;
        gameMessage = "Player 2's Turn: Press Ready to Start!";
        isReady = false; // 次のプレイヤーに進む前にReadyをリセット
        isRolling = false; // Reset isRolling after the turn ends
      });
    } else {
      _determineWinner();
    }
  }

  int _calculateScore(List<int> dice) {
    dice.sort();
    if (dice[0] == 4 && dice[1] == 5 && dice[2] == 6) {
      return 50;
    } else if (dice[0] == 1 && dice[1] == 2 && dice[2] == 3) {
      return -50;
    } else if (dice[0] == dice[1] && dice[1] == dice[2]) {
      return 100 + dice[0];
    } else if (dice[0] == dice[1]) {
      return dice[2];
    } else if (dice[1] == dice[2]) {
      return dice[0];
    } else {
      return 0;
    }
  }

  void _determineWinner() {
    String winnerMessage;
    if (playerScores[0] > playerScores[1]) {
      winnerMessage = "Player 1 Wins!";
    } else if (playerScores[0] < playerScores[1]) {
      winnerMessage = "Player 2 Wins!";
    } else {
      winnerMessage = "It's a Draw!";
    }

    setState(() {
      gameMessage = winnerMessage;
    });
  }

  void _resetGame() {
    setState(() {
      currentPlayer = 1;
      playerScores = [0, 0];
      currentDiceValues = [1, 1, 1];
      gameMessage = "Player 1's Turn: Press Ready to Start!";
      isReady = false;
    });
  }

  void _startTurn() {
    setState(() {
      isReady = true;
      gameMessage = "Player $currentPlayer's Turn: Shake to Roll!";
    });
  }

  @override
  void dispose() {
    shakeTimer?.cancel();
    _diceRotationController1.dispose();
    _diceRotationController2.dispose();
    _diceRotationController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チンチロゲーム'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              gameMessage,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // サイコロの間隔を広げる
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0), // 間隔を広げる
                      child: Dice(
                        value: currentDiceValues[0],
                        rotationController: _diceRotationController1,
                        angleOffset: pi / 6,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0), // 間隔を広げる
                      child: Dice(
                        value: currentDiceValues[1],
                        rotationController: _diceRotationController2,
                        angleOffset: -pi / 6,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0), // 間隔を広げる
                      child: Dice(
                        value: currentDiceValues[2],
                        rotationController: _diceRotationController3,
                        angleOffset: pi / 6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Player 1 Score: ${playerScores[0]}',
                style: const TextStyle(fontSize: 18)),
            Text('Player 2 Score: ${playerScores[1]}',
                style: const TextStyle(fontSize: 18)),
            if (gameMessage.contains("Wins") || gameMessage.contains("Draw"))
              ElevatedButton(
                onPressed: _resetGame,
                child: const Text('Play Again'),
              ),
            if (!isReady)
              ElevatedButton(
                onPressed: _startTurn,
                child: const Text('Ready'),
              ),
          ],
        ),
      ),
    );
  }
}

class Dice extends StatelessWidget {
  final int value;
  final AnimationController rotationController;
  final double angleOffset;

  const Dice({
    Key? key,
    required this.value,
    required this.rotationController,
    required this.angleOffset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: rotationController.value * 2 * pi + angleOffset,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                value.toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
