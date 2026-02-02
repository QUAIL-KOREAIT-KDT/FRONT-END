import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/game/mold_tile_model.dart';

/// 개별 곰팡이 타일 위젯
class MoldTile extends StatelessWidget {
  final MoldTileModel tile;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  const MoldTile({
    super.key,
    required this.tile,
    this.isSelected = false,
    this.size = 32,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tile.isRemoved) {
      // 제거된 타일은 빈 공간
      return SizedBox(width: size, height: size);
    }

    // ========================================
    // 🔧 곰팡이 크기 설정 (모든 숫자 동일 크기)
    // ========================================
    // 기본 크기 비율 (0.0 ~ 1.0, 타일 대비 곰팡이 크기)
    const double moldSizeRatio = 0.80; // ← 곰팡이 크기 조절
    // 선택 시 확대 비율
    const double selectedScale = 1.1; // ← 선택 시 확대 비율

    final double baseSize = size * moldSizeRatio;
    final double displaySize = isSelected ? baseSize * selectedScale : baseSize;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: displaySize,
          height: displaySize,
          decoration: BoxDecoration(
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.mintPrimary.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 곰팡이 이미지 (mold.png 하나만 사용)
              Image.asset(
                'assets/game/mold.png',
                width: displaySize,
                height: displaySize,
                fit: BoxFit.contain,
              ),
              // ========================================
              // 🔧 숫자 오버레이 설정
              // ========================================
              Positioned(
                // 숫자 위치 조절 (bottom: 0 이면 맨 아래, 숫자를 높이려면 값 증가)
                bottom: displaySize * 0.22, // ← 숫자 세로 위치 (0.0 ~ 1.0)
                child: Text(
                  tile.value.toString(),
                  style: TextStyle(
                    // ========================================
                    // 🔧 숫자 크기 조절
                    // ========================================
                    fontSize: displaySize * 0.45, // ← 숫자 크기 (곰팡이 대비 비율)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 터지는 애니메이션이 적용된 곰팡이 타일 (떨어지는 효과)
class AnimatedMoldTile extends StatefulWidget {
  final MoldTileModel tile;
  final bool isSelected;
  final double size;
  final bool shouldPop;
  final VoidCallback? onPopComplete;

  const AnimatedMoldTile({
    super.key,
    required this.tile,
    this.isSelected = false,
    this.size = 32,
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
  late Animation<double> _opacityAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600), // 떨어지는 시간
      vsync: this,
    );

    // 통통 튀면서 아래로 떨어지는 애니메이션
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -15, end: 80)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 85,
      ),
    ]).animate(_controller);

    // 크기가 줄어들면서 사라짐
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPopComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedMoldTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPop && !oldWidget.shouldPop) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tile.isRemoved && !widget.shouldPop) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (widget.shouldPop) {
          // 터질 때: 통통 튀면서 아래로 떨어짐 (숫자 없이 곰팡이만)
          final displaySize = widget.size * 0.80;
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Center(
                  child: Image.asset(
                    'assets/game/mold.png',
                    width: displaySize,
                    height: displaySize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          );
        }
        return MoldTile(
          tile: widget.tile,
          isSelected: widget.isSelected,
          size: widget.size,
        );
      },
    );
  }
}
