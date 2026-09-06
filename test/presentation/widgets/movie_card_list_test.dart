import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  testWidgets('should display movie title and overview',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieCard(testMovie),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(testMovie.title!), findsOneWidget);
    expect(find.text(testMovie.overview!), findsOneWidget);
  });

  testWidgets('should navigate to detail page when tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MovieCard(testMovie),
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
