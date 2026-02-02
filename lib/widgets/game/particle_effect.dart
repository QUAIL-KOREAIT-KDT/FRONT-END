import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// 파티클 이펙트 위젯 (이미지 기반 - 경량화)
class ParticleEffect extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback? onComplete;

  const ParticleEffect({
    super.key,
    required this.position,
    this.color = AppTheme.mintPrimary,
    this.onComplete,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ImageParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250), // 경량화: 300 → 250ms
      vsync: this,
    );

    _generateParticles();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  void _generateParticles() {
    final random = Random();
    // 경량화: 12 → 6개로 축소
    _particles = List.generate(6, (index) {
      final angle = (index * 60) * (pi / 180); // 60도 간격
      final speed = random.nextDouble() * 25 + 15;
      return _ImageParticle(
        angle: angle,
        speed: speed,
        size: random.nextDouble() * 12 + 8,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final distance = particle.speed * _controller.value;
            final x = widget.position.dx + cos(particle.angle) * distance;
            final y = widget.position.dy + sin(particle.angle) * distance;
            final opacity = (1 - _controller.value).clamp(0.0, 1.0);
            final size = particle.size * (1 - _controller.value * 0.5);

            return Positioned(
              left: x - size / 2,
              top: y - size / 2,
              child: Opacity(
                opacity: opacity,
                child: Image.asset(
                  'assets/game/effect_sparkle.png',
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ImageParticle {
  final double angle;
  final double speed;
  final double size;

  _ImageParticle({
    required this.angle,
    required this.speed,
    required this.size,
  });
}

/// 점수 팝업 애니메이션 위젯
class ScorePopup extends StatefulWidget {
  final int score;
  final Offset position;
  final VoidCallback? onComplete;

  const ScorePopup({
    super.key,
    required this.score,
    required this.position,
    this.onComplete,
  });

  @override
  State<ScorePopup> createState() => _ScorePopupState();
}

class _ScorePopupState extends State<ScorePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // 경량화: 600 → 400ms
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx - 20,
          top: widget.position.dy + _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.mintPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${widget.score}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 콤보 텍스트 오버레이 (경량화)
class ComboOverlay extends StatefulWidget {
  final int combo;
  final VoidCallback? onComplete;

  const ComboOverlay({
    super.key,
    required this.combo,
    this.onComplete,
  });

  @override
  State<ComboOverlay> createState() => _ComboOverlayState();
}

class _ComboOverlayState extends State<ComboOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // 경량화: 500 → 400ms
      vsync: this,
    );

    // 경량화: elasticOut 제거, 단순한 easeOut 사용
    _scaleAnimation = Tween<double>(begin: 1.5, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 콤보 이펙트 이미지
                  Image.asset(
                    'assets/game/effect_combo.png',
                    width: 120,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                  // 콤보 숫자 오버레이
                  Positioned(
                    right: 20,
                    child: Text(
                      '×${widget.combo}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0xFFFF6B6B),
                            blurRadius: 4,
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
      },
    );
  }
}
