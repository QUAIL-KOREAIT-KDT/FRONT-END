import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/game/mold_tile_model.dart';

/// 개별 곰팡이 타일 위젯
class MoldTile extends StatelessWidget {
  final MoldTileModel tile;
  final bool isSelected;
  final double tileSize; // 정사각형 크기
  final VoidCallback? onTap;

  const MoldTile({
    super.key,
    required this.tile,
    this.isSelected = false,
    this.tileSize = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tile.isRemoved) {
      return SizedBox(width: tileSize, height: tileSize);
    }

    final fontSize = tileSize * 0.45;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: tileSize,
        height: tileSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.mintPrimary.withOpacity(0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Image.asset(
                'assets/game/mold.png',
                width: tileSize,
                height: tileSize,
                fit: BoxFit.contain, // contain으로 정원형 유지
              ),
            ),
            Text(
              tile.value.toString(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 2,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 나뭇잎 떨어지기 애니메이션이 적용된 곰팡이 타일
/// - Transform.translate/rotate만 사용 (레이아웃 재계산 없음)
/// - 좌우 흔들림(wobble) + 가속 낙하(fall) + 페이드아웃(fade)
class AnimatedMoldTile extends StatefulWidget {
  final MoldTileModel tile;
  final bool isSelected;
  final double tileSize; // 정사각형 크기
  final bool shouldPop;
  final VoidCallback? onPopComplete;

  const AnimatedMoldTile({
    super.key,
    required this.tile,
    this.isSelected = false,
    this.tileSize = 32,
    this.shouldPop = false,
    this.onPopComplete,
  });

  @override
  State<AnimatedMoldTile> createState() => _AnimatedMoldTileState();
}

class _AnimatedMoldTileState extends State<AnimatedMoldTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fallAnimation;
  late Animation<double> _wobbleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _horizontalDriftAnimation;

  // 깜빡임 방지: 애니메이션 완료 상태 추적
  bool _isAnimationCompleted = false;

  // 각 타일마다 랜덤한 방향/세기로 떨어지도록
  late final double _wobbleDirection; // 1.0 or -1.0
  late final double _driftAmount; // 수평 이동량

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _wobbleDirection = rng.nextBool() ? 1.0 : -1.0;
    _driftAmount = (rng.nextDouble() * 20 - 10); // -10 ~ +10px

    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // 가속도 붙으며 아래로 떨어짐 (0 → 120px)
    _fallAnimation = Tween<double>(begin: 0, end: 120).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInQuad, // 가속
      ),
    );

    // 좌우 흔들림 (사인 웨이브 2회전, ±15도)
    _wobbleAnimation = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // 수평 드리프트 (살짝 옆으로 밀림)
    _horizontalDriftAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // 페이드 아웃 (후반부에 빠르게)
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // 애니메이션 완료 상태 저장 (깜빡임 방지)
        if (mounted) {
          setState(() {
            _isAnimationCompleted = true;
          });
        }
        widget.onPopComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedMoldTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 새 게임 시작 감지: id는 같지만 실제 데이터가 다른 새 타일
    final tileReplaced = oldWidget.tile.value != widget.tile.value ||
        oldWidget.tile.row != widget.tile.row ||
        oldWidget.tile.col != widget.tile.col ||
        (oldWidget.tile.isRemoved && !widget.tile.isRemoved);

    if (tileReplaced) {
      _isAnimationCompleted = false;
      _controller.reset();
      return;
    }

    // 팝 애니메이션 시작
    if (widget.shouldPop && !oldWidget.shouldPop) {
      _isAnimationCompleted = false;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 제거된 타일이고 애니메이션 중이 아니면 빈 공간
    if (widget.tile.isRemoved && !widget.shouldPop) {
      return SizedBox(width: widget.tileSize, height: widget.tileSize);
    }

    // 애니메이션 완료 후 깜빡임 방지: opacity 0 유지
    if (_isAnimationCompleted) {
      return SizedBox(width: widget.tileSize, height: widget.tileSize);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.shouldPop) {
          // 나뭇잎 떨어지기: translate + rotate + opacity
          final wobbleAngle =
              sin(_wobbleAnimation.value) * 0.26 * _wobbleDirection; // ±15도
          final dx = _horizontalDriftAnimation.value * _driftAmount;
          final dy = _fallAnimation.value;

          return SizedBox(
            width: widget.tileSize,
            height: widget.tileSize,
            child: Transform.translate(
              offset: Offset(dx, dy),
              child: Transform.rotate(
                angle: wobbleAngle,
                child: Opacity(
                  opacity: _opacityAnimation.value.clamp(0.0, 1.0),
                  child: Image.asset(
                    'assets/game/mold.png',
                    width: widget.tileSize,
                    height: widget.tileSize,
                    fit: BoxFit.contain, // contain으로 정원형 유지
                  ),
                ),
              ),
            ),
          );
        }
        return MoldTile(
          tile: widget.tile,
          isSelected: widget.isSelected,
          tileSize: widget.tileSize,
        );
      },
    );
  }
}
