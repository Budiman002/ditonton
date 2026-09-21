import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/bloc/movie/movie_detail_bloc.dart';
import 'package:ditonton/presentation/pages/movie_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockMovieDetailBloc
    extends MockBloc<MovieDetailEvent, MovieDetailState>
    implements MovieDetailBloc {}

class FakeMovieDetailEvent extends Fake implements MovieDetailEvent {}

class FakeMovieDetailState extends Fake implements MovieDetailState {}

void main() {
  late MockMovieDetailBloc mockBloc;

  final initialState = MovieDetailState.initial();

  setUpAll(() {
    registerFallbackValue(FakeMovieDetailEvent());
    registerFallbackValue(FakeMovieDetailState());
  });

  setUp(() {
    mockBloc = MockMovieDetailBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<MovieDetailBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  final loadedState = initialState.copyWith(
    movieDetailState: RequestState.Loaded,
    movieDetail: testMovieDetail,
    recommendationState: RequestState.Loaded,
    movieRecommendations: testMovieList,
  );

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(initialState.copyWith(movieDetailState: RequestState.Loading));

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display detail content when loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));

    expect(find.byType(DetailContent), findsOneWidget);
    expect(find.text(testMovieDetail.title), findsOneWidget);
  });

  testWidgets('Page should display error message when detail fails',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(initialState.copyWith(
      movieDetailState: RequestState.Error,
      message: 'Server Failure',
    ));

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));

    expect(find.text('Server Failure'), findsOneWidget);
  });

  testWidgets('Page should dispatch FetchMovieDetail and LoadWatchlistStatus '
      'on init', (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(initialState);

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));

    verify(() => mockBloc.add(FetchMovieDetail(1))).called(1);
    verify(() => mockBloc.add(LoadWatchlistStatus(1))).called(1);
  });

  testWidgets('Watchlist button should display add icon when not in watchlist',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Watchlist button should display check icon when in watchlist',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(loadedState.copyWith(isAddedToWatchlist: true));

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Watchlist button should dispatch AddToWatchlist when tapped',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(() => mockBloc.add(AddToWatchlist(testMovieDetail))).called(1);
  });

  testWidgets(
      'Watchlist button should dispatch RemoveFromWatchlist when already added',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(loadedState.copyWith(isAddedToWatchlist: true));

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(() => mockBloc.add(RemoveFromWatchlist(testMovieDetail))).called(1);
  });

  testWidgets('SnackBar should appear when watchlist add succeeds',
      (WidgetTester tester) async {
    whenListen(
      mockBloc,
      Stream<MovieDetailState>.fromIterable([
        loadedState,
        loadedState.copyWith(
          watchlistMessage: MovieDetailBloc.watchlistAddSuccessMessage,
          isAddedToWatchlist: true,
        ),
      ]),
      initialState: loadedState,
    );

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text(MovieDetailBloc.watchlistAddSuccessMessage),
      findsOneWidget,
    );
  });

  testWidgets('SnackBar should appear when watchlist remove succeeds',
      (WidgetTester tester) async {
    whenListen(
      mockBloc,
      Stream<MovieDetailState>.fromIterable([
        loadedState.copyWith(isAddedToWatchlist: true),
        loadedState.copyWith(
          watchlistMessage: MovieDetailBloc.watchlistRemoveSuccessMessage,
          isAddedToWatchlist: false,
        ),
      ]),
      initialState: loadedState.copyWith(isAddedToWatchlist: true),
    );

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text(MovieDetailBloc.watchlistRemoveSuccessMessage),
      findsOneWidget,
    );
  });

  testWidgets('AlertDialog should appear when watchlist message is a failure',
      (WidgetTester tester) async {
    whenListen(
      mockBloc,
      Stream<MovieDetailState>.fromIterable([
        loadedState,
        loadedState.copyWith(watchlistMessage: 'Failed'),
      ]),
      initialState: loadedState,
    );

    await tester.pumpWidget(makeTestableWidget(MovieDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });
}
