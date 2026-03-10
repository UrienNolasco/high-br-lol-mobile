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

      expect(
        find.descendant(
          of: find.byType(RotatingIcon),
          matching: find.byType(RotationTransition),
        ),
        findsOneWidget,
      );

      // Advance animation and verify it's still running
      await tester.pump(const Duration(milliseconds: 750));
      expect(
        find.descendant(
          of: find.byType(RotatingIcon),
          matching: find.byType(RotationTransition),
        ),
        findsOneWidget,
      );
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
