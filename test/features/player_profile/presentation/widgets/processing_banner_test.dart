import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:high_br_lol_mobile/features/player_profile/presentation/bloc/player_profile_state.dart';
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

  Widget buildBanner({
    required BannerMode bannerMode,
    ProcessingStatus? status,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ProcessingBanner(
          bannerMode: bannerMode,
          status: status,
          onTap: onTap,
        ),
      ),
    );
  }

  group('ProcessingBanner - processing mode', () {
    testWidgets('renders RotatingIcon and WaveText', (tester) async {
      await tester.pumpWidget(buildBanner(
        bannerMode: BannerMode.processing,
        status: tStatus,
      ));
      expect(find.byType(RotatingIcon), findsOneWidget);
      expect(find.byType(WaveText), findsOneWidget);
      expect(find.byType(AnimatedCounterBuilder), findsOneWidget);
    });

    testWidgets('is not tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildBanner(
        bannerMode: BannerMode.processing,
        status: tStatus,
        onTap: () => tapped = true,
      ));
      await tester.tap(find.byType(ProcessingBanner));
      expect(tapped, isFalse);
    });
  });

  group('ProcessingBanner - ready mode', () {
    testWidgets('renders static icon, text, and chevron', (tester) async {
      await tester.pumpWidget(buildBanner(bannerMode: BannerMode.ready));
      expect(find.text('Buscar mais partidas'), findsOneWidget);
      expect(find.byIcon(Icons.manage_search), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byType(RotatingIcon), findsNothing);
    });

    testWidgets('is tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildBanner(
        bannerMode: BannerMode.ready,
        onTap: () => tapped = true,
      ));
      await tester.tap(find.byType(ProcessingBanner));
      expect(tapped, isTrue);
    });
  });

  group('ProcessingBanner - triggering mode', () {
    testWidgets('renders RotatingIcon and WaveText with triggering text',
        (tester) async {
      await tester.pumpWidget(buildBanner(bannerMode: BannerMode.triggering));
      expect(find.byType(RotatingIcon), findsOneWidget);
      expect(find.byType(WaveText), findsOneWidget);
    });

    testWidgets('is not tappable', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildBanner(
        bannerMode: BannerMode.triggering,
        onTap: () => tapped = true,
      ));
      await tester.tap(find.byType(ProcessingBanner));
      expect(tapped, isFalse);
    });
  });
}
