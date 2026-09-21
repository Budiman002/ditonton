import 'package:bloc_test/bloc_test.dart';
import 'package:ditonton/presentation/bloc/tv/search_tvs_bloc.dart';
import 'package:ditonton/presentation/pages/search_tv_page.dart';
import 'package:ditonton/presentation/widgets/tv_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../dummy_data/dummy_objects.dart';

class MockSearchTvsBloc extends MockBloc<SearchTvsEvent, SearchTvsState>
    implements SearchTvsBloc {}

class FakeSearchTvsEvent extends Fake implements SearchTvsEvent {}

class FakeSearchTvsState extends Fake implements SearchTvsState {}

void main() {
  late MockSearchTvsBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakeSearchTvsEvent());
    registerFallbackValue(FakeSearchTvsState());
  });

  setUp(() {
    mockBloc = MockSearchTvsBloc();
  });

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<SearchTvsBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets('Page should display progress bar when loading',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(SearchTvsLoading());

    await tester.pumpWidget(makeTestableWidget(SearchTvPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Page should display ListView when data is loaded',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(SearchTvsHasData(testTvList));

    await tester.pumpWidget(makeTestableWidget(SearchTvPage()));

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TvCard), findsOneWidget);
    expect(find.text(testTv.name!), findsOneWidget);
  });

  testWidgets('Page should display text with message when Error',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(SearchTvsError('Error message'));

    await tester.pumpWidget(makeTestableWidget(SearchTvPage()));

    expect(find.byKey(Key('error_message')), findsOneWidget);
    expect(find.text('Error message'), findsOneWidget);
  });

  testWidgets('Page should dispatch OnQueryChanged when query is submitted',
      (WidgetTester tester) async {
    when(() => mockBloc.state).thenReturn(SearchTvsEmpty());

    await tester.pumpWidget(makeTestableWidget(SearchTvPage()));

    await tester.enterText(find.byType(TextField), 'game of thrones');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();

    verify(() => mockBloc.add(OnQueryChanged('game of thrones'))).called(1);
  });
}
