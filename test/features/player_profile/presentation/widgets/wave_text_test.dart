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
      final transforms = find.descendant(
        of: find.byType(WaveText),
        matching: find.byType(Transform),
      );
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

      expect(
        find.descendant(
          of: find.byType(WaveText),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
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

      final transforms = tester.widgetList<Transform>(
        find.descendant(
          of: find.byType(WaveText),
          matching: find.byType(Transform),
        ),
      ).toList();
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
