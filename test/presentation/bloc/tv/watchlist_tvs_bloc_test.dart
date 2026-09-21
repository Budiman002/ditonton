import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tvs.dart';
import 'package:ditonton/presentation/bloc/tv/watchlist_tvs_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../dummy_data/dummy_objects.dart';
import 'watchlist_tvs_bloc_test.mocks.dart';

@GenerateMocks([GetWatchlistTvs])
void main() {
  late MockGetWatchlistTvs mockGetWatchlistTvs;
  late WatchlistTvsBloc watchlistTvsBloc;

  setUp(() {
    mockGetWatchlistTvs = MockGetWatchlistTvs();
    watchlistTvsBloc = WatchlistTvsBloc(mockGetWatchlistTvs);
  });

  test('initial state should be empty', () {
    expect(watchlistTvsBloc.state, WatchlistTvsEmpty());
  });

  blocTest<WatchlistTvsBloc, WatchlistTvsState>(
    'should emit [Loading, HasData] when data is gotten successfully',
    build: () {
      when(mockGetWatchlistTvs.execute())
          .thenAnswer((_) async => Right(testTvList));
      return watchlistTvsBloc;
    },
    act: (bloc) => bloc.add(FetchWatchlistTvs()),
    expect: () => [
      WatchlistTvsLoading(),
      WatchlistTvsHasData(testTvList),
    ],
    verify: (_) {
      verify(mockGetWatchlistTvs.execute());
    },
  );

  blocTest<WatchlistTvsBloc, WatchlistTvsState>(
    'should emit [Loading, Error] when getting data is unsuccessful',
    build: () {
      when(mockGetWatchlistTvs.execute())
          .thenAnswer((_) async => Left(DatabaseFailure("Can't get data")));
      return watchlistTvsBloc;
    },
    act: (bloc) => bloc.add(FetchWatchlistTvs()),
    expect: () => [
      WatchlistTvsLoading(),
      WatchlistTvsError("Can't get data"),
    ],
    verify: (_) {
      verify(mockGetWatchlistTvs.execute());
    },
  );
}
