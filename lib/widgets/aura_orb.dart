import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/mood.dart';

/// The living gradient orb — the signature element of the app.
/// Blurred, drifting blobs whose colors morph smoothly whenever the mood changes.
class AuraOrb extends StatefulWidget {
  final Mood mood;
  final double jitter;

  const AuraOrb({super.key, required this.mood, required this.jitter});

  @override
  State<AuraOrb> createState() => _AuraOrbState();
}

class _Particle {
  final double x0, y0, r, phaseSeed, speed;
  final int colorIdx; // index into palette: 1=base, 2=core, 3=glow
  const _Particle(this.x0, this.y0, this.r, this.phaseSeed, this.speed, this.colorIdx);
}

class _AuraOrbState extends State<AuraOrb> with TickerProviderStateMixin {
  late final AnimationController _ticker; // free-running clock for particle motion
  late final AnimationController _transition; // 0->1 blend between mood changes
  late List<HSLColor> _fromPalette;
  late List<HSLColor> _toPalette;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(days: 1))..repeat();
    _transition = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _toPalette = buildPalette(widget.mood, jitter: widget.jitter);
    _fromPalette = _toPalette;
    _transition.value = 1.0;
    _seedParticles();
  }

  void _seedParticles() {
    final rnd = math.Random(7);
    _particles.clear();
    for (int i = 0; i < 7; i++) {
      _particles.add(_Particle(
        rnd.nextDouble(),
        rnd.nextDouble(),
        0.22 + rnd.nextDouble() * 0.28,
        rnd.nextDouble() * math.pi * 2,
        0.00015 + rnd.nextDouble() * 0.0003,
        1 + rnd.nextInt(3),
      ));
    }
  }

  @override
  void didUpdateWidget(covariant AuraOrb old) {
    super.didUpdateWidget(old);
    if (old.mood.key != widget.mood.key || old.jitter != widget.jitter) {
      final t = _transition.value;
      // freeze current interpolated state as the new "from"
      _fromPalette = List.generate(
        5,
        (i) => lerpHsl(_fromPalette[i], _toPalette[i], t),
      );
      _toPalette = buildPalette(widget.mood, jitter: widget.jitter);
      _transition
        ..value = 0
        ..forward();
    }
  }

  double get _speedMultiplier {
    switch (widget.mood.motion) {
      case MoodMotion.fast:
        return 2.1;
      case MoodMotion.drift:
        return 1.3;
      case MoodMotion.slow:
        return 0.7;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_ticker, _transition]),
      builder: (context, _) {
        final elapsedMs = _ticker.lastElapsedDuration?.inMilliseconds.toDouble() ?? 0.0;
        final palette = List.generate(
          5,
          (i) => lerpHsl(_fromPalette[i], _toPalette[i], _transition.value),
        );
        return CustomPaint(
          size: Size.infinite,
          painter: _OrbPainter(
            palette: palette,
            particles: _particles,
            elapsedMs: elapsedMs,
            speedMultiplier: _speedMultiplier,
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final List<HSLColor> palette;
  final List<_Particle> particles;
  final double elapsedMs;
  final double speedMultiplier;

  _OrbPainter({
    required this.palette,
    required this.particles,
    required this.elapsedMs,
    required this.speedMultiplier,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    // base ink
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0B0B10));

    // radial wash from the 'deep' tone
    final deep = palette[0];
    final washCenter = Offset(w * 0.5, h * 0.55);
    final washRadius = math.max(w, h) * 0.75;
    final washPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          deep.withSaturation((deep.saturation * 0.5)).withLightness(math.max(deep.lightness, 0.10)).toColor(),
          const Color(0xFF08080C),
        ],
      ).createShader(Rect.fromCircle(center: washCenter, radius: washRadius));
    canvas.drawCircle(washCenter, washRadius, washPaint);

    // drifting blurred blobs, additive "screen"-like blend
    for (final p in particles) {
      final phase = p.phaseSeed + p.speed * speedMultiplier * elapsedMs;
      final x = (p.x0 + math.sin(phase) * 0.06) * w;
      final y = (p.y0 + math.cos(phase * 0.85) * 0.06) * h;
      final rad = p.r * math.min(w, h) * (0.9 + 0.1 * math.sin(phase * 1.3));
      final c = palette[p.colorIdx];

      final blobPaint = Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            c.withLightness(_clamp01(c.lightness + 0.06)).toColor(),
            c.toColor(),
            c.toColor().withOpacity(0.0),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: rad));

      canvas.drawCircle(Offset(x, y), rad, blobPaint);
    }

    // vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0x00000000), Color(0x73000000)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(w * 0.5, h * 0.5),
        radius: math.max(w, h) * 0.75,
      ));
    canvas.drawRect(rect, vignette);
  }

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}