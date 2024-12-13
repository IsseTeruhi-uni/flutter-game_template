import 'package:flutter/material.dart';

/// ループアニメーション用ウィジェット
class LoopBackGround extends StatelessWidget {
  /// グラデーションのオフセット
  final Animation<Offset> gradationAnimation;

  /// アニメーションの再生、リピートなどを操作するコントローラー
  final AnimationController animationController;

  /// 内部に配置するウィジェット
  final Widget? child;

  /// アニメーションを表示する領域の横幅
  final double? fullWidth;

  /// アニメーションの有無
  final bool isAnimation;

  /// 初期値のオフセット
  final Offset? initialOffset;

  const LoopBackGround({
    required this.gradationAnimation,
    required this.animationController,
    this.child,
    this.fullWidth,
    this.isAnimation = true,
    this.initialOffset,
  });

  final gradateBeginColor = const Color.fromARGB(255, 220, 40, 110);
  final gradateEndColor = const Color.fromARGB(255, 0, 133, 255);

  @override
  Widget build(BuildContext context) {
    final backgroundBoxDecoration = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        gradateBeginColor,
        gradateEndColor,
        gradateBeginColor,
        gradateEndColor,
        gradateBeginColor,
      ],
      stops: const [
        0.0,
        0.25,
        0.5,
        0.75,
        1.0,
      ],
    );

    return AnimatedBuilder(
      animation: animationController,
      child: child,
      builder: (BuildContext context, child) {
        return Stack(
          children: [
            Positioned(
              child: Transform.translate(
                offset: isAnimation
                    ? gradationAnimation.value + (initialOffset ?? Offset.zero)
                    : initialOffset ?? Offset.zero,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  primary: false,
                  child: SizedBox(
                    width: fullWidth ?? MediaQuery.of(context).size.width * 5,
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: backgroundBoxDecoration,
                        borderRadius: BorderRadius.circular(6),
                      ), // 直接gradationを埋め込む
                    ),
                  ),
                ),
              ),
            ),
            if (child != null)
              Positioned(
                child: child,
              ),
          ],
        );
      },
    );
  }
}
