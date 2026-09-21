import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/tv/popular_tvs_bloc.dart';
import 'package:ditonton/presentation/pages/popular_tvs_page.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockPopularTvsBloc extends MockBloc<PopularTvsEvent, PopularTvsState>
    implements PopularTvsBloc {}

class FakePopularTvsEvent extends Fake implements PopularTvsEvent {}

class FakePopularTvsState extends Fake implements PopularTvsState {}

void main() {
  late MockPopularTvsBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakePopularTvsEvent());
    registerFallbackValue(FakePopularTvsState());
  });

  setUp(() {
    mockBloc = MockPopularTvsBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<PopularTvsBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(PopularTvsLoading());

    await tester.pumpWidget(makeTestableWidget(PopularTvsPage()));

    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display ListView when data is loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(PopularTvsHasData(testTvList));

    await tester.pumpWidget(makeTestableWidget(PopularTvsPage()));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TvCard), findsOneWidget);
    expect(find.text(testTv.name!), findsOneWidget);
  });

  testWidgets('Page should display text with message when Error',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(PopularTvsError('Error message'));

    await tester.pumpWidget(makeTestableWidget(PopularTvsPage()));

    expect(find.byKey(Key('error_message')), findsOneWidget);
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('Page should dispatch FetchPopularTvs on init',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(PopularTvsEmpty());

    await tester.pumpWidget(makeTestableWidget(PopularTvsPage()));

    verify(() => mockBloc.add(FetchPopularTvs())).called(1);
  });
}
