import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/usecases/get_tv_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tv_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist_tv.dart';
import 'package:ditonton/domain/usecases/save_watchlist_tv.dart';
import 'package:ditonton/presentation/bloc/tv/tv_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../dummy_data/dummy_objects.dart';
import 'tv_detail_bloc_test.mocks.dart';

@GenerateMocks([
  GetTvDetail,
  GetTvRecommendations,
  GetWatchListTvStatus,
  SaveWatchlistTv,
  RemoveWatchlistTv,
])
void main() {
  late MockGetTvDetail mockGetTvDetail;
  late MockGetTvRecommendations mockGetTvRecommendations;
  late MockGetWatchListTvStatus mockGetWatchlistTvStatus;
  late MockSaveWatchlistTv mockSaveWatchlistTv;
  late MockRemoveWatchlistTv mockRemoveWatchlistTv;
  late TvDetailBloc tvDetailBloc;

  const tId = 1;

  setUp(() {
    mockGetTvDetail = MockGetTvDetail();
    mockGetTvRecommendations = MockGetTvRecommendations();
    mockGetWatchlistTvStatus = MockGetWatchListTvStatus();
    mockSaveWatchlistTv = MockSaveWatchlistTv();
    mockRemoveWatchlistTv = MockRemoveWatchlistTv();
    tvDetailBloc = TvDetailBloc(
      getTvDetail: mockGetTvDetail,
      getTvRecommendations: mockGetTvRecommendations,
      getWatchListTvStatus: mockGetWatchlistTvStatus,
      saveWatchlistTv: mockSaveWatchlistTv,
      removeWatchlistTv: mockRemoveWatchlistTv,
    );
  });

  final initialState = TvDetailState.initial();

  test('initial state should be the empty detail state', () {
    expect(tvDetailBloc.state, initialState);
  });

  group('FetchTvDetail', () {
    blocTest<TvDetailBloc, TvDetailState>(
      'should emit Loading then Loaded detail with loaded recommendations',
      build: () {
        when(mockGetTvDetail.execute(tId))
            .thenAnswer((_) async => Right(testTvDetail));
        when(mockGetTvRecommendations.execute(tId))
            .thenAnswer((_) async => Right(testTvList));
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(FetchTvDetail(tId)),
      expect: () => [
        initialState.copyWith(tvDetailState: RequestState.Loading),
        initialState.copyWith(
          tvDetailState: RequestState.Loading,
          recommendationState: RequestState.Loading,
          tvDetail: testTvDetail,
        ),
        initialState.copyWith(
          tvDetailState: RequestState.Loaded,
          recommendationState: RequestState.Loaded,
          tvDetail: testTvDetail,
          tvRecommendations: testTvList,
        ),
      ],
      verify: (_) {
        verify(mockGetTvDetail.execute(tId));
        verify(mockGetTvRecommendations.execute(tId));
      },
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'should emit Loading then Error when getting detail fails',
      build: () {
        when(mockGetTvDetail.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        when(mockGetTvRecommendations.execute(tId))
            .thenAnswer((_) async => Right(testTvList));
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(FetchTvDetail(tId)),
      expect: () => [
        initialState.copyWith(tvDetailState: RequestState.Loading),
        initialState.copyWith(
          tvDetailState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'should load detail but mark recommendations as Error when they fail',
      build: () {
        when(mockGetTvDetail.execute(tId))
            .thenAnswer((_) async => Right(testTvDetail));
        when(mockGetTvRecommendations.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Failed')));
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(FetchTvDetail(tId)),
      expect: () => [
        initialState.copyWith(tvDetailState: RequestState.Loading),
        initialState.copyWith(
          tvDetailState: RequestState.Loading,
          recommendationState: RequestState.Loading,
          tvDetail: testTvDetail,
        ),
        initialState.copyWith(
          tvDetailState: RequestState.Loaded,
          recommendationState: RequestState.Error,
          tvDetail: testTvDetail,
          message: 'Failed',
        ),
      ],
    );
  });

  group('Watchlist', () {
    blocTest<TvDetailBloc, TvDetailState>(
      'AddToWatchlist should emit success message then added status',
      build: () {
        when(mockSaveWatchlistTv.execute(testTvDetail)).thenAnswer(
            (_) async => Right(TvDetailBloc.watchlistAddSuccessMessage));
        when(mockGetWatchlistTvStatus.execute(testTvDetail.id))
            .thenAnswer((_) async => true);
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(AddToWatchlist(testTvDetail)),
      expect: () => [
        initialState.copyWith(
          watchlistMessage: TvDetailBloc.watchlistAddSuccessMessage,
        ),
        initialState.copyWith(
          watchlistMessage: TvDetailBloc.watchlistAddSuccessMessage,
          isAddedToWatchlist: true,
        ),
      ],
      verify: (_) {
        verify(mockSaveWatchlistTv.execute(testTvDetail));
        verify(mockGetWatchlistTvStatus.execute(testTvDetail.id));
      },
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'AddToWatchlist should emit failure message when saving fails',
      build: () {
        when(mockSaveWatchlistTv.execute(testTvDetail))
            .thenAnswer((_) async => Left(DatabaseFailure('Failed')));
        when(mockGetWatchlistTvStatus.execute(testTvDetail.id))
            .thenAnswer((_) async => false);
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(AddToWatchlist(testTvDetail)),
      expect: () => [
        initialState.copyWith(watchlistMessage: 'Failed'),
      ],
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'RemoveFromWatchlist should emit success message then removed status',
      build: () {
        when(mockRemoveWatchlistTv.execute(testTvDetail)).thenAnswer(
            (_) async => Right(TvDetailBloc.watchlistRemoveSuccessMessage));
        when(mockGetWatchlistTvStatus.execute(testTvDetail.id))
            .thenAnswer((_) async => false);
        return tvDetailBloc;
      },
      seed: () => initialState.copyWith(isAddedToWatchlist: true),
      act: (bloc) => bloc.add(RemoveFromWatchlist(testTvDetail)),
      expect: () => [
        initialState.copyWith(
          isAddedToWatchlist: true,
          watchlistMessage: TvDetailBloc.watchlistRemoveSuccessMessage,
        ),
        initialState.copyWith(
          isAddedToWatchlist: false,
          watchlistMessage: TvDetailBloc.watchlistRemoveSuccessMessage,
        ),
      ],
      verify: (_) {
        verify(mockRemoveWatchlistTv.execute(testTvDetail));
        verify(mockGetWatchlistTvStatus.execute(testTvDetail.id));
      },
    );

    blocTest<TvDetailBloc, TvDetailState>(
      'LoadWatchlistStatus should emit the status returned by the use case',
      build: () {
        when(mockGetWatchlistTvStatus.execute(tId))
            .thenAnswer((_) async => true);
        return tvDetailBloc;
      },
      act: (bloc) => bloc.add(LoadWatchlistStatus(tId)),
      expect: () => [
        initialState.copyWith(isAddedToWatchlist: true),
      ],
      verify: (_) {
        verify(mockGetWatchlistTvStatus.execute(tId));
      },
    );
  });
}
