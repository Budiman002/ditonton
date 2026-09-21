import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/presentation/bloc/tv/tv_detail_bloc.dart';
import 'package:ditonton/presentation/pages/tv_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockTvDetailBloc extends MockBloc<TvDetailEvent, TvDetailState>
    implements TvDetailBloc {}

class FakeTvDetailEvent extends Fake implements TvDetailEvent {}

class FakeTvDetailState extends Fake implements TvDetailState {}

void main() {
  late MockTvDetailBloc mockBloc;

  final initialState = TvDetailState.initial();

  setUpAll(() {
    registerFallbackValue(FakeTvDetailEvent());
    registerFallbackValue(FakeTvDetailState());
  });

  setUp(() {
    mockBloc = MockTvDetailBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<TvDetailBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  final loadedState = initialState.copyWith(
    tvDetailState: RequestState.Loaded,
    tvDetail: testTvDetail,
    recommendationState: RequestState.Loaded,
    tvRecommendations: testTvList,
  );

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(initialState.copyWith(tvDetailState: RequestState.Loading));

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display detail content when loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    expect(find.byType(DetailContent), findsOneWidget);
    expect(find.text(testTvDetail.name), findsOneWidget);
  });

  testWidgets('Page should keep the seasons section when loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    expect(find.text('Seasons'), findsOneWidget);
    expect(
      find.text(
        '${testTvDetail.numberOfSeasons} Seasons - '
        '${testTvDetail.numberOfEpisodes} Episodes',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Page should display error message when detail fails',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(initialState.copyWith(
      tvDetailState: RequestState.Error,
      message: 'Server Failure',
    ));

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    expect(find.text('Server Failure'), findsOneWidget);
  });

  testWidgets(
      'Page should dispatch FetchTvDetail and LoadWatchlistStatus on init',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(initialState);

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    verify(() => mockBloc.add(FetchTvDetail(1))).called(1);
    verify(() => mockBloc.add(LoadWatchlistStatus(1))).called(1);
  });

  testWidgets('Watchlist button should display add icon when not in watchlist',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Watchlist button should display check icon when in watchlist',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(loadedState.copyWith(isAddedToWatchlist: true));

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Watchlist button should dispatch AddToWatchlist when tapped',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(loadedState);

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(() => mockBloc.add(AddToWatchlist(testTvDetail))).called(1);
  });

  testWidgets(
      'Watchlist button should dispatch RemoveFromWatchlist when already added',
      (WidgetTester tester) async {
    when(() => mockBloc.state)
        .thenReturn(loadedState.copyWith(isAddedToWatchlist: true));

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    verify(() => mockBloc.add(RemoveFromWatchlist(testTvDetail))).called(1);
  });

  testWidgets('SnackBar should appear when watchlist add succeeds',
      (WidgetTester tester) async {
    whenListen(
      mockBloc,
      Stream<TvDetailState>.fromIterable([
        loadedState,
        loadedState.copyWith(
          watchlistMessage: TvDetailBloc.watchlistAddSuccessMessage,
          isAddedToWatchlist: true,
        ),
      ]),
      initialState: loadedState,
    );

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(TvDetailBloc.watchlistAddSuccessMessage), findsOneWidget);
  });

  testWidgets('SnackBar should appear when watchlist remove succeeds',
      (WidgetTester tester) async {
    whenListen(
      mockBloc,
      Stream<TvDetailState>.fromIterable([
        loadedState.copyWith(isAddedToWatchlist: true),
        loadedState.copyWith(
          watchlistMessage: TvDetailBloc.watchlistRemoveSuccessMessage,
          isAddedToWatchlist: false,
        ),
      ]),
      initialState: loadedState.copyWith(isAddedToWatchlist: true),
    );

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text(TvDetailBloc.watchlistRemoveSuccessMessage),
      findsOneWidget,
    );
  });

  testWidgets('AlertDialog should appear when watchlist message is a failure',
      (WidgetTester tester) async {
    whenListen(
      mockBloc,
      Stream<TvDetailState>.fromIterable([
        loadedState,
        loadedState.copyWith(watchlistMessage: 'Failed'),
      ]),
      initialState: loadedState,
    );

    await tester.pumpWidget(makeTestableWidget(TvDetailPage(id: 1)));
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });
}
