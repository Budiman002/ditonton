import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/movie/now_playing_movies_bloc.dart';
import 'package:ditonton/presentation/bloc/movie/popular_movies_bloc.dart';
import 'package:ditonton/presentation/bloc/movie/top_rated_movies_bloc.dart';
import 'package:ditonton/presentation/pages/home_movie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockNowPlayingMoviesBloc
    extends MockBloc<NowPlayingMoviesEvent, NowPlayingMoviesState>
    implements NowPlayingMoviesBloc {}

class MockPopularMoviesBloc
    extends MockBloc<PopularMoviesEvent, PopularMoviesState>
    implements PopularMoviesBloc {}

class MockTopRatedMoviesBloc
    extends MockBloc<TopRatedMoviesEvent, TopRatedMoviesState>
    implements TopRatedMoviesBloc {}

class FakeNowPlayingMoviesEvent extends Fake
    implements NowPlayingMoviesEvent {}

class FakeNowPlayingMoviesState extends Fake
    implements NowPlayingMoviesState {}

class FakePopularMoviesEvent extends Fake implements PopularMoviesEvent {}

class FakePopularMoviesState extends Fake implements PopularMoviesState {}

class FakeTopRatedMoviesEvent extends Fake implements TopRatedMoviesEvent {}

class FakeTopRatedMoviesState extends Fake implements TopRatedMoviesState {}

void main() {
  late MockNowPlayingMoviesBloc mockNowPlayingBloc;
  late MockPopularMoviesBloc mockPopularBloc;
  late MockTopRatedMoviesBloc mockTopRatedBloc;

  setUpAll(() {
    registerFallbackValue(FakeNowPlayingMoviesEvent());
    registerFallbackValue(FakeNowPlayingMoviesState());
    registerFallbackValue(FakePopularMoviesEvent());
    registerFallbackValue(FakePopularMoviesState());
    registerFallbackValue(FakeTopRatedMoviesEvent());
    registerFallbackValue(FakeTopRatedMoviesState());
  });

  setUp(() {
    mockNowPlayingBloc = MockNowPlayingMoviesBloc();
    mockPopularBloc = MockPopularMoviesBloc();
    mockTopRatedBloc = MockTopRatedMoviesBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NowPlayingMoviesBloc>.value(value: mockNowPlayingBloc),
        BlocProvider<PopularMoviesBloc>.value(value: mockPopularBloc),
        BlocProvider<TopRatedMoviesBloc>.value(value: mockTopRatedBloc),
      ],
      child: MaterialApp(
        home: body,
      ),
    );
  }

  void stubAll({
    NowPlayingMoviesState? nowPlaying,
    PopularMoviesState? popular,
    TopRatedMoviesState? topRated,
  }) {
    when(() => mockNowPlayingBloc.state)
        .thenReturn(nowPlaying ?? NowPlayingMoviesEmpty());
    when(() => mockPopularBloc.state)
        .thenReturn(popular ?? PopularMoviesEmpty());
    when(() => mockTopRatedBloc.state)
        .thenReturn(topRated ?? TopRatedMoviesEmpty());
  }

  testWidgets('Page should dispatch all three fetch events on init',
      (WidgetTester tester) async {
    stubAll();

    await tester.pumpWidget(makeTestableWidget(HomeMoviePage()));

    verify(() => mockNowPlayingBloc.add(FetchNowPlayingMovies())).called(1);
    verify(() => mockPopularBloc.add(FetchPopularMovies())).called(1);
    verify(() => mockTopRatedBloc.add(FetchTopRatedMovies())).called(1);
  });

  testWidgets('Each section should display progress bar when loading',
      (WidgetTester tester) async {
    stubAll(
      nowPlaying: NowPlayingMoviesLoading(),
      popular: PopularMoviesLoading(),
      topRated: TopRatedMoviesLoading(),
    );

    await tester.pumpWidget(makeTestableWidget(HomeMoviePage()));

    expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
  });

  testWidgets('Each section should display MovieList when data is loaded',
      (WidgetTester tester) async {
    stubAll(
      nowPlaying: NowPlayingMoviesHasData(testMovieList),
      popular: PopularMoviesHasData(testMovieList),
      topRated: TopRatedMoviesHasData(testMovieList),
    );

    await tester.pumpWidget(makeTestableWidget(HomeMoviePage()));

    expect(find.byType(MovieList), findsNWidgets(3));
  });

  testWidgets('Each section should display Failed text when error',
      (WidgetTester tester) async {
    stubAll(
      nowPlaying: NowPlayingMoviesError('Server Failure'),
      popular: PopularMoviesError('Server Failure'),
      topRated: TopRatedMoviesError('Server Failure'),
    );

    await tester.pumpWidget(makeTestableWidget(HomeMoviePage()));

    expect(find.text('Failed'), findsNWidgets(3));
  });

  testWidgets('Sections should render independently per bloc state',
      (WidgetTester tester) async {
    stubAll(
      nowPlaying: NowPlayingMoviesLoading(),
      popular: PopularMoviesHasData(testMovieList),
      topRated: TopRatedMoviesError('Server Failure'),
    );

    await tester.pumpWidget(makeTestableWidget(HomeMoviePage()));

    // scoped to the Now Playing section: MovieList's CachedNetworkImage
    // placeholder is also a CircularProgressIndicator, so a global count
    // would not tell the sections apart.
    expect(
      find.descendant(
        of: find.byType(BlocBuilder<NowPlayingMoviesBloc,
            NowPlayingMoviesState>),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byType(MovieList), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('Page should keep See More buttons for Popular and Top Rated',
      (WidgetTester tester) async {
    stubAll();

    await tester.pumpWidget(makeTestableWidget(HomeMoviePage()));

    expect(find.text('See More'), findsNWidgets(2));
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
  });
}
