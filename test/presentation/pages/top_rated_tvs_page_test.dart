import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/tv/top_rated_tvs_bloc.dart';
import 'package:ditonton/presentation/pages/top_rated_tvs_page.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockTopRatedTvsBloc extends MockBloc<TopRatedTvsEvent, TopRatedTvsState>
    implements TopRatedTvsBloc {}

class FakeTopRatedTvsEvent extends Fake implements TopRatedTvsEvent {}

class FakeTopRatedTvsState extends Fake implements TopRatedTvsState {}

void main() {
  late MockTopRatedTvsBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeTopRatedTvsEvent());
    registerFallbackValue(FakeTopRatedTvsState());
  });

  setUp(() {
    mockBloc = MockTopRatedTvsBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<TopRatedTvsBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(TopRatedTvsLoading());

    await tester.pumpWidget(makeTestableWidget(TopRatedTvsPage()));

    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display when data is loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(TopRatedTvsHasData(testTvList));

    await tester.pumpWidget(makeTestableWidget(TopRatedTvsPage()));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TvCard), findsOneWidget);
    expect(find.text(testTv.name!), findsOneWidget);
  });

  testWidgets('Page should display text with message when Error',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(TopRatedTvsError('Error message'));

    await tester.pumpWidget(makeTestableWidget(TopRatedTvsPage()));

    expect(find.byKey(Key('error_message')), findsOneWidget);
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('Page should dispatch FetchTopRatedTvs on init',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(TopRatedTvsEmpty());

    await tester.pumpWidget(makeTestableWidget(TopRatedTvsPage()));

    verify(() => mockBloc.add(FetchTopRatedTvs())).called(1);
  });
}
