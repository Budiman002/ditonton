import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/common/utils.dart';
import 'package:ditonton/presentation/bloc/movie/watchlist_movies_bloc.dart';
import 'package:ditonton/presentation/pages/watchlist_movies_page.dart';
import 'package:ditonton/presentation/widgets/movie_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockWatchlistMoviesBloc
    extends MockBloc<WatchlistMoviesEvent, WatchlistMoviesState>
    implements WatchlistMoviesBloc {}

class FakeWatchlistMoviesEvent extends Fake implements WatchlistMoviesEvent {}

class FakeWatchlistMoviesState extends Fake implements WatchlistMoviesState {}

void main() {
  late MockWatchlistMoviesBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeWatchlistMoviesEvent());
    registerFallbackValue(FakeWatchlistMoviesState());
  });

  setUp(() {
    mockBloc = MockWatchlistMoviesBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<WatchlistMoviesBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
        navigatorObservers: [routeObserver],
      ),
    );
  }

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistMoviesLoading());

    await tester.pumpWidget(makeTestableWidget(WatchlistMoviesPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display ListView when data is loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistMoviesHasData(testMovieList));

    await tester.pumpWidget(makeTestableWidget(WatchlistMoviesPage()));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text(testMovie.title!), findsOneWidget);
  });

  testWidgets('Page should display text with message when Error',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(WatchlistMoviesError("Can't get data"));

    await tester.pumpWidget(makeTestableWidget(WatchlistMoviesPage()));

    expect(find.byKey(Key('error_message')), findsOneWidget);
    expect(find.text("Can't get data"), findsOneWidget);
  });

  testWidgets('Page should dispatch FetchWatchlistMovies on init',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistMoviesEmpty());

    await tester.pumpWidget(makeTestableWidget(WatchlistMoviesPage()));

    verify(() => mockBloc.add(FetchWatchlistMovies())).called(1);
  });

  testWidgets(
      'Page should re-dispatch FetchWatchlistMovies on didPopNext '
      '(back from another route)', (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(WatchlistMoviesEmpty());

    await tester.pumpWidget(makeTestableWidget(WatchlistMoviesPage()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(WatchlistMoviesPage));

    // push another route, then pop back -> didPopNext fires
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => Scaffold(body: Text('detail'))),
    );
    await tester.pumpAndSettle();

    Navigator.of(context).pop();
    await tester.pumpAndSettle();

    // once from initState, once from didPopNext
    verify(() => mockBloc.add(FetchWatchlistMovies())).called(2);
  });
}
