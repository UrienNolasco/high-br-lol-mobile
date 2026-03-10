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
