import 'package:cached_network_image/cached_network_image.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/presentation/pages/home_tv_page.dart';
import 'package:ditonton/presentation/provider/tv_list_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../dummy_data/dummy_objects.dart';
import 'home_tv_page_test.mocks.dart';

@GenerateMocks([TvListNotifier])
void main() {
  late MockTvListNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockTvListNotifier();
  });

  Widget _makeTestableWidget(Widget body) {
    return ChangeNotifierProvider<TvListNotifier>.value(
      value: mockNotifier,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets('Page should display all sections when data is loaded',
      (WidgetTester tester) async {
    when(mockNotifier.onTheAirState).thenReturn(RequestState.Loaded);
    when(mockNotifier.onTheAirTvs).thenReturn(<Tv>[testTv]);
    when(mockNotifier.popularTvsState).thenReturn(RequestState.Loaded);
    when(mockNotifier.popularTvs).thenReturn(<Tv>[testTv]);
    when(mockNotifier.topRatedTvsState).thenReturn(RequestState.Loaded);
    when(mockNotifier.topRatedTvs).thenReturn(<Tv>[testTv]);

    await tester.pumpWidget(_makeTestableWidget(HomeTvPage()));

    expect(find.byType(TvList), findsNWidgets(3));
    expect(find.byType(CachedNetworkImage), findsNWidgets(3));
    expect(find.text('On The Air'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
  });

  testWidgets('Page should display progress bar when a section is loading',
      (WidgetTester tester) async {
    when(mockNotifier.onTheAirState).thenReturn(RequestState.Loading);
    when(mockNotifier.popularTvsState).thenReturn(RequestState.Loaded);
    when(mockNotifier.popularTvs).thenReturn(<Tv>[]);
    when(mockNotifier.topRatedTvsState).thenReturn(RequestState.Loaded);
    when(mockNotifier.topRatedTvs).thenReturn(<Tv>[]);

    await tester.pumpWidget(_makeTestableWidget(HomeTvPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TvList), findsNWidgets(2));
  });

  testWidgets('Page should display failed text when a section is error',
      (WidgetTester tester) async {
    when(mockNotifier.onTheAirState).thenReturn(RequestState.Error);
    when(mockNotifier.popularTvsState).thenReturn(RequestState.Loaded);
    when(mockNotifier.popularTvs).thenReturn(<Tv>[testTv]);
    when(mockNotifier.topRatedTvsState).thenReturn(RequestState.Loaded);
    when(mockNotifier.topRatedTvs).thenReturn(<Tv>[testTv]);

    await tester.pumpWidget(_makeTestableWidget(HomeTvPage()));

    expect(find.text('Failed'), findsOneWidget);
    expect(find.byType(TvList), findsNWidgets(2));
  });
}
