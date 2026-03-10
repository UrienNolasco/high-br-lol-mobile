// lib/features/player_profile/presentation/widgets/wave_text.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveText extends StatefulWidget {
  const WaveText({
    super.key,
    required this.text,
    required this.style,
    this.amplitude = 3.0,
    this.pauseDuration = const Duration(seconds: 2),
  });

  final String text;
  final TextStyle style;
  final double amplitude;
  final Duration pauseDuration;

  @override
  State<WaveText> createState() => _WaveTextState();
}

class _WaveTextState extends State<WaveText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _pauseTimer;

  static const double _waveWidth = 0.3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _calculateDuration(),
      vsync: this,
    );
    _controller.addStatusListener(_onAnimationStatus);
    _controller.forward();
  }

  @override
  void didUpdateWidget(WaveText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text.length != widget.text.length) {
      _controller.duration = _calculateDuration();
    }
  }

  Duration _calculateDuration() {
    // 50ms per character, scaled up so the wave fully traverses the last chars.
    // Without this, the last ~30% of characters would have their wave clipped
    // because progress maxes at 1.0 but the wave window extends past them.
    return Duration(
      milliseconds: (widget.text.length * 50 / (1.0 - _waveWidth)).round(),
    );
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _pauseTimer?.cancel();
      _pauseTimer = Timer(widget.pauseDuration, () {
        if (!mounted) return;
        _controller.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.text.length, (index) {
              final offset = _calculateOffset(index);
              return Transform.translate(
                offset: Offset(0, offset),
                child: Text(
                  widget.text[index],
                  style: widget.style,
                ),
              );
            }),
          );
        },
      ),
    );
  }

  double _calculateOffset(int index) {
    // The wave progresses left-to-right as _controller.value goes 0→1.
    // Each character has a "window" where it participates in the wave.
    // Progress is scaled by (1 + waveWidth) so the wave fully exits
    // past the last character before the animation completes.
    final progress = _controller.value * (1.0 + _waveWidth);
    final charCount = widget.text.length;

    // Normalize index position [0, 1]
    final charPosition = index / charCount;

    // The wave front moves from 0 to (1 + waveWidth). Each char activates
    // when the wave front reaches it and deactivates shortly after.
    final distance = progress - charPosition;

    if (distance < 0 || distance > _waveWidth) {
      return 0;
    }

    // Sin curve within the active window
    final t = distance / _waveWidth;
    return -math.sin(t * math.pi) * widget.amplitude;
  }
}
