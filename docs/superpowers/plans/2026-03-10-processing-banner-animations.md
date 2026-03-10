# Processing Banner Animations Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the static ProcessingBanner into an animated component with rotating icon, wave text effect, and sequential number counting.

**Architecture:** Three independent animated widgets (RotatingIcon, WaveText, AnimatedCounterBuilder) composed inside the existing ProcessingBanner. Each widget manages its own animation lifecycle. No BLoC changes needed.

**Tech Stack:** Flutter animations (AnimationController, Transform, SingleTickerProviderStateMixin), dart:async Timer, dart:math sin/pi.

---

## File Structure

| Action | File | Responsibility |
|--------|------|---------------|
| Create | `lib/features/player_profile/presentation/widgets/rotating_icon.dart` | Continuously rotating icon widget |
| Create | `lib/features/player_profile/presentation/widgets/wave_text.dart` | Text with wave animation effect |
| Create | `lib/features/player_profile/presentation/widgets/animated_counter_builder.dart` | Builder widget that counts sequentially to target value |
| Modify | `lib/features/player_profile/presentation/widgets/processing_banner.dart` | Compose the three animated widgets |
| Create | `test/features/player_profile/presentation/widgets/rotating_icon_test.dart` | Tests for RotatingIcon |
| Create | `test/features/player_profile/presentation/widgets/wave_text_test.dart` | Tests for WaveText |
| Create | `test/features/player_profile/presentation/widgets/animated_counter_builder_test.dart` | Tests for AnimatedCounterBuilder |
| Create | `test/features/player_profile/presentation/widgets/processing_banner_test.dart` | Tests for composed ProcessingBanner |

---

## Chunk 1: RotatingIcon Widget

### Task 1: Create RotatingIcon widget with test

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/rotating_icon.dart`
- Create: `test/features/player_profile/presentation/widgets/rotating_icon_test.dart`

- [ ] **Step 1: Write the test file**

```dart
// test/features/player_profile/presentation/widgets/rotating_icon_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/rotating_icon.dart';

void main() {
  group('RotatingIcon', () {
    testWidgets('renders the provided icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RotatingIcon(
              icon: Icons.sync,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('uses RotationTransition for animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RotatingIcon(
              icon: Icons.sync,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(RotationTransition), findsOneWidget);

      // Advance animation and verify it's still running
      await tester.pump(const Duration(milliseconds: 750));
      expect(find.byType(RotationTransition), findsOneWidget);
    });

    testWidgets('disposes animation controller without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RotatingIcon(
              icon: Icons.sync,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      );

      // Remove widget from tree — should not throw
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/player_profile/presentation/widgets/rotating_icon_test.dart`
Expected: FAIL — `rotating_icon.dart` does not exist yet.

- [ ] **Step 3: Write the RotatingIcon implementation**

```dart
// lib/features/player_profile/presentation/widgets/rotating_icon.dart
import 'package:flutter/material.dart';

class RotatingIcon extends StatefulWidget {
  const RotatingIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/player_profile/presentation/widgets/rotating_icon_test.dart`
Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/player_profile/presentation/widgets/rotating_icon.dart test/features/player_profile/presentation/widgets/rotating_icon_test.dart
git commit -m "feat: add RotatingIcon widget with continuous 360° spin animation"
```

---

## Chunk 2: AnimatedCounterBuilder Widget

### Task 2: Create AnimatedCounterBuilder widget with test

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/animated_counter_builder.dart`
- Create: `test/features/player_profile/presentation/widgets/animated_counter_builder_test.dart`

- [ ] **Step 1: Write the test file**

```dart
// test/features/player_profile/presentation/widgets/animated_counter_builder_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/animated_counter_builder.dart';

void main() {
  group('AnimatedCounterBuilder', () {
    testWidgets('displays initial target value immediately', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCounterBuilder(
              target: 5,
              builder: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('counts sequentially when target increases', (tester) async {
      int currentTarget = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    AnimatedCounterBuilder(
                      target: currentTarget,
                      builder: (context, value) =>
                          Text('$value', key: const Key('counter')),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => currentTarget = 6),
                      child: const Text('update'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);

      // Tap button to update target from 3 to 6
      await tester.tap(find.text('update'));
      await tester.pump();

      // After 250ms: should show 4
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('4'), findsOneWidget);

      // After another 250ms: should show 5
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('5'), findsOneWidget);

      // After another 250ms: should show 6
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('jumps directly when new target is lower', (tester) async {
      int currentTarget = 10;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    AnimatedCounterBuilder(
                      target: currentTarget,
                      builder: (context, value) => Text('$value'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => currentTarget = 2),
                      child: const Text('reset'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('10'), findsOneWidget);

      await tester.tap(find.text('reset'));
      await tester.pump();

      // Should jump directly to 2
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('updates target while already counting', (tester) async {
      int currentTarget = 1;

      late void Function(void Function()) setOuterState;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              setOuterState = setState;
              return Scaffold(
                body: AnimatedCounterBuilder(
                  target: currentTarget,
                  builder: (context, value) => Text('$value'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);

      // Set target to 5
      setOuterState(() => currentTarget = 5);
      await tester.pump();

      // Count to 2
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('2'), findsOneWidget);

      // Now update target to 8 mid-count
      setOuterState(() => currentTarget = 8);
      await tester.pump();

      // Should continue counting from 2 towards 8
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('cancels timer on dispose', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCounterBuilder(
              target: 5,
              builder: (context, value) => Text('$value'),
            ),
          ),
        ),
      );

      // Remove widget — should not throw
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );

      // Pump some time to make sure no timer callbacks fire on disposed widget
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/player_profile/presentation/widgets/animated_counter_builder_test.dart`
Expected: FAIL — `animated_counter_builder.dart` does not exist yet.

- [ ] **Step 3: Write the AnimatedCounterBuilder implementation**

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/player_profile/presentation/widgets/animated_counter_builder_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/player_profile/presentation/widgets/animated_counter_builder.dart test/features/player_profile/presentation/widgets/animated_counter_builder_test.dart
git commit -m "feat: add AnimatedCounterBuilder with sequential counting at 250ms intervals"
```

---

## Chunk 3: WaveText Widget

### Task 3: Create WaveText widget with test

**Files:**
- Create: `lib/features/player_profile/presentation/widgets/wave_text.dart`
- Create: `test/features/player_profile/presentation/widgets/wave_text_test.dart`

- [ ] **Step 1: Write the test file**

```dart
// test/features/player_profile/presentation/widgets/wave_text_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/wave_text.dart';

void main() {
  group('WaveText', () {
    testWidgets('renders all characters of the text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveText(
              text: 'ABC',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('applies Transform.translate to each character', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveText(
              text: 'Hi',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      );

      // Each character should be wrapped in a Transform widget
      final transforms = find.byType(Transform);
      expect(transforms, findsNWidgets(2));
    });

    testWidgets('wraps content in RepaintBoundary', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveText(
              text: 'Test',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('characters have non-zero Y offset during wave animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveText(
              text: 'ABCDE',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      );

      // Advance to mid-animation — some characters should be displaced
      await tester.pump(const Duration(milliseconds: 125));

      final transforms = tester.widgetList<Transform>(find.byType(Transform)).toList();
      final offsets = transforms.map((t) => t.transform.getTranslation().y).toList();

      // At least one character should have a non-zero Y offset
      expect(offsets.any((y) => y != 0), isTrue);
    });

    testWidgets('updates text when widget changes', (tester) async {
      String text = 'AB';

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    WaveText(
                      text: text,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => text = 'XYZ'),
                      child: const Text('change'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);

      await tester.tap(find.text('change'));
      await tester.pump();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
      expect(find.text('Z'), findsOneWidget);
    });

    testWidgets('disposes animation controller without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WaveText(
              text: 'Test',
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/player_profile/presentation/widgets/wave_text_test.dart`
Expected: FAIL — `wave_text.dart` does not exist yet.

- [ ] **Step 3: Write the WaveText implementation**

```dart
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/player_profile/presentation/widgets/wave_text_test.dart`
Expected: All 5 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/features/player_profile/presentation/widgets/wave_text.dart test/features/player_profile/presentation/widgets/wave_text_test.dart
git commit -m "feat: add WaveText widget with character-by-character wave animation"
```

---

## Chunk 4: Compose ProcessingBanner

### Task 4: Refactor ProcessingBanner to use animated widgets

**Files:**
- Modify: `lib/features/player_profile/presentation/widgets/processing_banner.dart`
- Create: `test/features/player_profile/presentation/widgets/processing_banner_test.dart`

- [ ] **Step 1: Write the test file**

```dart
// test/features/player_profile/presentation/widgets/processing_banner_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/processing_banner.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/rotating_icon.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/wave_text.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/widgets/animated_counter_builder.dart';
import 'package:high_br_lol_mobile/features/player_search/domain/entities/processing_status.dart';

void main() {
  const tStatus = ProcessingStatus(
    status: UpdateStatus.updating,
    matchesProcessed: 5,
    matchesTotal: 20,
    message: 'Processing',
  );

  group('ProcessingBanner', () {
    testWidgets('renders RotatingIcon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProcessingBanner(status: tStatus),
          ),
        ),
      );

      expect(find.byType(RotatingIcon), findsOneWidget);
    });

    testWidgets('renders WaveText', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProcessingBanner(status: tStatus),
          ),
        ),
      );

      expect(find.byType(WaveText), findsOneWidget);
    });

    testWidgets('renders AnimatedCounterBuilder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProcessingBanner(status: tStatus),
          ),
        ),
      );

      expect(find.byType(AnimatedCounterBuilder), findsOneWidget);
    });

    testWidgets('displays correct match count text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProcessingBanner(status: tStatus),
          ),
        ),
      );

      // The text "Processando partidas... " plus "5" and "/20" should be present
      // Characters are split individually in WaveText, so check for /20 parts
      expect(find.text('/'), findsOneWidget);
    });

    testWidgets('has full-width blue container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProcessingBanner(status: tStatus),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/player_profile/presentation/widgets/processing_banner_test.dart`
Expected: FAIL — ProcessingBanner is still a StatelessWidget without the new widgets.

- [ ] **Step 3: Rewrite ProcessingBanner to compose animated widgets**

Replace the entire content of `processing_banner.dart` with:

```dart
// lib/features/player_profile/presentation/widgets/processing_banner.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player_search/domain/entities/processing_status.dart';
import 'animated_counter_builder.dart';
import 'rotating_icon.dart';
import 'wave_text.dart';

class ProcessingBanner extends StatelessWidget {
  const ProcessingBanner({super.key, required this.status});

  final ProcessingStatus status;

  static const _textStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.accent.withValues(alpha: 0.9),
      child: AnimatedCounterBuilder(
        target: status.matchesProcessed,
        builder: (context, displayValue) {
          return Row(
            children: [
              const RotatingIcon(
                icon: Icons.sync,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              WaveText(
                text: 'Processando partidas... $displayValue/${status.matchesTotal}',
                style: _textStyle,
              ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run all tests to verify everything passes**

Run: `flutter test test/features/player_profile/presentation/widgets/`
Expected: All tests PASS across all 4 test files.

- [ ] **Step 5: Run full test suite**

Run: `flutter test`
Expected: All existing tests still PASS. No regressions.

- [ ] **Step 6: Commit**

```bash
git add lib/features/player_profile/presentation/widgets/processing_banner.dart test/features/player_profile/presentation/widgets/processing_banner_test.dart
git commit -m "feat: refactor ProcessingBanner to compose RotatingIcon, WaveText, and AnimatedCounterBuilder"
```
