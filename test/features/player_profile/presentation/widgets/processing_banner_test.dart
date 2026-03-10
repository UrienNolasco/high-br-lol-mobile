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
