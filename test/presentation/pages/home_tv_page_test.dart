import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/tv/on_the_air_tvs_bloc.dart';
import 'package:ditonton/presentation/bloc/tv/popular_tvs_bloc.dart';
import 'package:ditonton/presentation/bloc/tv/top_rated_tvs_bloc.dart';
import 'package:ditonton/presentation/pages/home_tv_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockOnTheAirTvsBloc extends MockBloc<OnTheAirTvsEvent, OnTheAirTvsState>
    implements OnTheAirTvsBloc {}

class MockPopularTvsBloc extends MockBloc<PopularTvsEvent, PopularTvsState>
    implements PopularTvsBloc {}

class MockTopRatedTvsBloc extends MockBloc<TopRatedTvsEvent, TopRatedTvsState>
    implements TopRatedTvsBloc {}

class FakeOnTheAirTvsEvent extends Fake implements OnTheAirTvsEvent {}

class FakeOnTheAirTvsState extends Fake implements OnTheAirTvsState {}

class FakePopularTvsEvent extends Fake implements PopularTvsEvent {}

class FakePopularTvsState extends Fake implements PopularTvsState {}

class FakeTopRatedTvsEvent extends Fake implements TopRatedTvsEvent {}

class FakeTopRatedTvsState extends Fake implements TopRatedTvsState {}

void main() {
  late MockOnTheAirTvsBloc mockOnTheAirBloc;
  late MockPopularTvsBloc mockPopularBloc;
  late MockTopRatedTvsBloc mockTopRatedBloc;

  setUpAll(() {
    registerFallbackValue(FakeOnTheAirTvsEvent());
    registerFallbackValue(FakeOnTheAirTvsState());
    registerFallbackValue(FakePopularTvsEvent());
    registerFallbackValue(FakePopularTvsState());
    registerFallbackValue(FakeTopRatedTvsEvent());
    registerFallbackValue(FakeTopRatedTvsState());
  });

  setUp(() {
    mockOnTheAirBloc = MockOnTheAirTvsBloc();
    mockPopularBloc = MockPopularTvsBloc();
    mockTopRatedBloc = MockTopRatedTvsBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OnTheAirTvsBloc>.value(value: mockOnTheAirBloc),
        BlocProvider<PopularTvsBloc>.value(value: mockPopularBloc),
        BlocProvider<TopRatedTvsBloc>.value(value: mockTopRatedBloc),
      ],
      child: MaterialApp(
        home: body,
      ),
    );
  }

  void stubAll({
    OnTheAirTvsState? onTheAir,
    PopularTvsState? popular,
    TopRatedTvsState? topRated,
  }) {
    when(() => mockOnTheAirBloc.state)
        .thenReturn(onTheAir ?? OnTheAirTvsEmpty());
    when(() => mockPopularBloc.state).thenReturn(popular ?? PopularTvsEmpty());
    when(() => mockTopRatedBloc.state)
        .thenReturn(topRated ?? TopRatedTvsEmpty());
  }

  testWidgets('Page should dispatch all three fetch events on init',
      (WidgetTester tester) async {
    stubAll();

    await tester.pumpWidget(makeTestableWidget(HomeTvPage()));

    verify(() => mockOnTheAirBloc.add(FetchOnTheAirTvs())).called(1);
    verify(() => mockPopularBloc.add(FetchPopularTvs())).called(1);
    verify(() => mockTopRatedBloc.add(FetchTopRatedTvs())).called(1);
  });

  testWidgets('Each section should display progress bar when loading',
      (WidgetTester tester) async {
    stubAll(
      onTheAir: OnTheAirTvsLoading(),
      popular: PopularTvsLoading(),
      topRated: TopRatedTvsLoading(),
    );

    await tester.pumpWidget(makeTestableWidget(HomeTvPage()));

    expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
  });

  testWidgets('Each section should display TvList when data is loaded',
      (WidgetTester tester) async {
    stubAll(
      onTheAir: OnTheAirTvsHasData(testTvList),
      popular: PopularTvsHasData(testTvList),
      topRated: TopRatedTvsHasData(testTvList),
    );

    await tester.pumpWidget(makeTestableWidget(HomeTvPage()));

    expect(find.byType(TvList), findsNWidgets(3));
  });

  testWidgets('Each section should display Failed text when error',
      (WidgetTester tester) async {
    stubAll(
      onTheAir: OnTheAirTvsError('Server Failure'),
      popular: PopularTvsError('Server Failure'),
      topRated: TopRatedTvsError('Server Failure'),
    );

    await tester.pumpWidget(makeTestableWidget(HomeTvPage()));

    expect(find.text('Failed'), findsNWidgets(3));
  });

  testWidgets('Sections should render independently per bloc state',
      (WidgetTester tester) async {
    stubAll(
      onTheAir: OnTheAirTvsLoading(),
      popular: PopularTvsHasData(testTvList),
      topRated: TopRatedTvsError('Server Failure'),
    );

    await tester.pumpWidget(makeTestableWidget(HomeTvPage()));

    // scoped to the On The Air section: TvList's CachedNetworkImage
    // placeholder is also a CircularProgressIndicator.
    expect(
      find.descendant(
        of: find.byType(BlocBuilder<OnTheAirTvsBloc, OnTheAirTvsState>),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.byType(TvList), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('Page should keep See More buttons for Popular and Top Rated',
      (WidgetTester tester) async {
    stubAll();

    await tester.pumpWidget(makeTestableWidget(HomeTvPage()));

    expect(find.text('See More'), findsNWidgets(2));
    expect(find.text('On The Air'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
  });
}
