import 'package:ditonton/presentation/pages/about_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget makeTestableWidget(Widget body) {
    return MaterialApp(
      home: body,
    );
  }

  const aboutText =
      'Ditonton merupakan sebuah aplikasi katalog film yang dikembangkan oleh '
      'Dicoding Indonesia sebagai contoh proyek aplikasi untuk kelas Menjadi '
      'Flutter Developer Expert.';

  testWidgets('Page should display the about text and the logo',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(AboutPage()));

    expect(find.text(aboutText), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Page should display a back button that pops the route',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AboutPage()),
            ),
            child: Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(AboutPage), findsNothing);
  });

  testWidgets('Page should no longer expose any debug action button',
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(AboutPage()));

    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Test Analytics'), findsNothing);
    expect(find.text('Test Crash'), findsNothing);
  });
}
