import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  testWidgets('should display tv name and overview',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvCard(testTv),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(testTv.name!), findsOneWidget);
    expect(find.text(testTv.overview!), findsOneWidget);
  });

  testWidgets('should navigate to detail page when tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TvCard(testTv),
        ),
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('DETAIL_PAGE')),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(InkWell));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('DETAIL_PAGE'), findsOneWidget);
  });
}
