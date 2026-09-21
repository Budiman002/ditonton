import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/bloc/tv/watchlist_tvs_bloc.dart';
import 'package:ditonton/presentation/pages/watchlist_tvs_page.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockWatchlistTvsBloc
    extends MockBloc<WatchlistTvsEvent, WatchlistTvsState>
    implements WatchlistTvsBloc {}

class FakeWatchlistTvsEvent extends Fake implements WatchlistTvsEvent {}

class FakeWatchlistTvsState extends Fake implements WatchlistTvsState {}

void main() {
  late MockWatchlistTvsBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeWatchlistTvsEvent());
    registerFallbackValue(FakeWatchlistTvsState());
  });

  setUp(() {
    mockBloc = MockWatchlistTvsBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<WatchlistTvsBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
        navigatorObservers: [routeObserver],
      ),
    );
  }

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistTvsLoading());

    await tester.pumpWidget(makeTestableWidget(WatchlistTvsPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display ListView when data is loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistTvsHasData(testTvList));

    await tester.pumpWidget(makeTestableWidget(WatchlistTvsPage()));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TvCard), findsOneWidget);
    expect(find.text(testTv.name!), findsOneWidget);
  });

  testWidgets('Page should display text with message when Error',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(WatchlistTvsError("Can't get data"));

    await tester.pumpWidget(makeTestableWidget(WatchlistTvsPage()));

    expect(find.byKey(Key('error_message')), findsOneWidget);
    expect(find.text("Can't get data"), findsOneWidget);
  });

  testWidgets('Page should dispatch FetchWatchlistTvs on init',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistTvsEmpty());

    await tester.pumpWidget(makeTestableWidget(WatchlistTvsPage()));

    verify(() => mockBloc.add(FetchWatchlistTvs())).called(1);
  });

  testWidgets(
      'Page should re-dispatch FetchWatchlistTvs on didPopNext '
      '(back from another route)', (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistTvsEmpty());

    await tester.pumpWidget(makeTestableWidget(WatchlistTvsPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(WatchlistTvsPage));

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Scaffold(body: Text('detail'))),
    );
    await tester.pumpAndSettle();

    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    // once from initState, once from didPopNext
    verify(() => mockBloc.add(FetchWatchlistTvs())).called(2);
  });
}
