import 'package:flutter/material.dart';
import 'package:finance_frontend/apptheme.dart';

/// Animated splash screen for the AI Finance & Expense Intelligence app.
///
/// Sequence: background rings fade in -> five bars rise in a staggered
/// equalizer motion -> an emerald "signal" line draws itself across the
/// bar tops -> circuit nodes pop in along the line -> the wordmark and
/// loading dots fade up. Total runtime is ~3.2s, then [onFinished] fires
/// so you can navigate to your real home / auth screen.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   home: AnimatedSplashScreen(
///     onFinished: () => Navigator.of(context).pushReplacement(
///       MaterialPageRoute(builder: (_) => const HomeScreen()),
///     ),
///   ),
/// )
/// ```
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({
    super.key,
    this.onFinished,
    this.appName = 'Finance AI',
    this.tagline = 'EXPENSE INTELLIGENCE',
  });

  final VoidCallback? onFinished;
  final String appName;
  final String tagline;

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Staggered intervals (0.0–1.0 of total controller duration).
  late final List<Animation<double>> _barAnims;
  late final Animation<double> _ringFade;
  late final Animation<double> _pulseDraw;
  late final Animation<double> _nodePop;
  late final Animation<double> _endpointPop;
  late final Animation<double> _wordmarkFade;
  late final Animation<double> _dotsFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _ringFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _barAnims = List.generate(5, (i) {
      final start = 0.05 + i * 0.04;
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, start + 0.17, curve: Curves.easeOutCubic),
      );
    });

    _pulseDraw = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.62, curve: Curves.easeInOutCubic),
    );

    _nodePop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.72, curve: Curves.elasticOut),
    );

    _endpointPop = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 0.78, curve: Curves.elasticOut),
    );

    _wordmarkFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
    );

    _dotsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) widget.onFinished?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.splashGradient,
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _ring(size: 420, opacity: _ringFade.value * 0.35),
                        _ring(size: 340, opacity: _ringFade.value * 0.25),
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: _SplashPainter(
                            barProgress: _barAnims.map((a) => a.value).toList(),
                            pulseProgress: _pulseDraw.value,
                            nodeProgress: _nodePop.value,
                            endpointProgress: _endpointPop.value,
                            barColors: AppColors.barColors,
                            emerald: AppColors.primary,
                            emeraldSoft: AppColors.primarySoft,
                            ink: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  Opacity(
                    opacity: _wordmarkFade.value,
                    child: Transform.translate(
                      offset: Offset(0, 10 * (1 - _wordmarkFade.value)),
                      child: Column(
                        children: [
                          Text(
                            widget.appName,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.tagline,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Opacity(
                    opacity: _dotsFade.value,
                    child: const _LoadingDots(color: AppColors.primary),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _ring({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.ring.withOpacity(opacity.clamp(0, 1)),
          width: 1,
        ),
      ),
    );
  }
}

/// Draws the rising bar chart + the "AI signal" pulse line + circuit nodes.
class _SplashPainter extends CustomPainter {
  _SplashPainter({
    required this.barProgress,
    required this.pulseProgress,
    required this.nodeProgress,
    required this.endpointProgress,
    required this.barColors,
    required this.emerald,
    required this.emeraldSoft,
    required this.ink,
  });

  final List<double> barProgress;
  final double pulseProgress;
  final double nodeProgress;
  final double endpointProgress;
  final List<Color> barColors;
  final Color emerald;
  final Color emeraldSoft;
  final Color ink;

  // Bar geometry, relative to the 260x260 canvas center.
  static const _barX = [-95.0, -58.0, -21.0, 16.0, 53.0];
  static const _barTopY = [-40.0, -50.0, -60.0, -50.0, -50.0]; // unused; kept simple below
  static const _barHeights = [45.0, 70.0, 105.0, 145.0, 180.0];
  static const _barWidth = 30.0;
  static const _baseY = 50.0; // bottom of bars

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // 1) Bars, growing from the baseline.
    for (var i = 0; i < 5; i++) {
      final h = _barHeights[i] * barProgress[i].clamp(0.0, 1.0);
      if (h <= 0) continue;
      final rect = Rect.fromLTWH(_barX[i], _baseY - h, _barWidth, h);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
      canvas.drawRRect(rrect, Paint()..color = barColors[i]);
    }

    // 2) Pulse line, drawn progressively via PathMetrics.
    final path = Path()
      ..moveTo(-108, 30)
      ..lineTo(-75, 30)
      ..lineTo(-60, -10)
      ..lineTo(-35, 60)
      ..lineTo(-8, -30)
      ..lineTo(15, 20)
      ..lineTo(40, -75)
      ..lineTo(57, -75)
      ..lineTo(80, -130);

    if (pulseProgress > 0) {
      final metrics = path.computeMetrics().toList();
      final totalLen = metrics.fold<double>(0, (sum, m) => sum + m.length);
      var remaining = totalLen * pulseProgress.clamp(0.0, 1.0);
      final drawPath = Path();
      for (final m in metrics) {
        if (remaining <= 0) break;
        final take = remaining >= m.length ? m.length : remaining;
        drawPath.addPath(m.extractPath(0, take), Offset.zero);
        remaining -= take;
      }

      final pulsePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(
          colors: [emerald, emeraldSoft],
        ).createShader(const Rect.fromLTWH(-108, -130, 188, 160));

      canvas.drawPath(drawPath, pulsePaint);
    }

    // 3) Circuit nodes at three interior vertices.
    if (nodeProgress > 0) {
      final nodePaint = Paint()..color = emeraldSoft;
      for (final p in const [Offset(-108, 30), Offset(-35, 60), Offset(15, 20)]) {
        canvas.drawCircle(p, 5 * nodeProgress.clamp(0.0, 1.0), nodePaint);
      }
    }

    // 4) End point + glow ring at the peak.
    if (endpointProgress > 0) {
      const peak = Offset(80, -130);
      canvas.drawCircle(
        peak,
        7 * endpointProgress.clamp(0.0, 1.0),
        Paint()..color = ink,
      );
      canvas.drawCircle(
        peak,
        13 * endpointProgress.clamp(0.0, 1.0),
        Paint()
          ..color = emeraldSoft.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SplashPainter old) {
    return old.barProgress != barProgress ||
        old.pulseProgress != pulseProgress ||
        old.nodeProgress != nodeProgress ||
        old.endpointProgress != endpointProgress;
  }
}

/// Three softly blinking dots used as a lightweight "thinking / loading" cue.
class _LoadingDots extends StatefulWidget {
  const _LoadingDots({required this.color});
  final Color color;

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
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
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_controller.value - i * 0.15) % 1.0;
            final opacity = 0.25 + 0.75 * (0.5 + 0.5 * (t < 0.4 ? (t / 0.4) : (1 - (t - 0.4) / 0.6)));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Opacity(
                opacity: opacity.clamp(0.25, 1.0),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
