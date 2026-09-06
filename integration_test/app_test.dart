import 'package:ditonton/presentation/pages/home_tv_page.dart';
import 'package:ditonton/presentation/pages/watchlist_tvs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:ditonton/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('end-to-end: buka fitur TV Series lalu watchlist TV',
      (WidgetTester tester) async {
    app.main();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byIcon(Icons.menu), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('TV Series'), findsOneWidget);

    await tester.tap(find.text('TV Series'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(HomeTvPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bookmark));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(WatchlistTvsPage), findsOneWidget);
  });
}
