// lib/features/player_profile/presentation/widgets/animated_counter_builder.dart
import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedCounterBuilder extends StatefulWidget {
  const AnimatedCounterBuilder({
    super.key,
    required this.target,
    required this.builder,
  });

  final int target;
  final Widget Function(BuildContext context, int displayValue) builder;

  @override
  State<AnimatedCounterBuilder> createState() => _AnimatedCounterBuilderState();
}

class _AnimatedCounterBuilderState extends State<AnimatedCounterBuilder> {
  late int _displayValue;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.target;
  }

  @override
  void didUpdateWidget(AnimatedCounterBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      if (widget.target < _displayValue) {
        // Target decreased (reset scenario) — jump directly
        _timer?.cancel();
        setState(() => _displayValue = widget.target);
      } else if (widget.target > _displayValue) {
        // Target increased — start or continue counting
        _startCounting();
      }
    }
  }

  void _startCounting() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_displayValue < widget.target) {
        setState(() => _displayValue++);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _displayValue);
  }
}
