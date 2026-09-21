import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:ditonton/presentation/bloc/movie/movie_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../dummy_data/dummy_objects.dart';
import 'movie_detail_bloc_test.mocks.dart';

@GenerateMocks([
  GetMovieDetail,
  GetMovieRecommendations,
  GetWatchListStatus,
  SaveWatchlist,
  RemoveWatchlist,
])
void main() {
  late MockGetMovieDetail mockGetMovieDetail;
  late MockGetMovieRecommendations mockGetMovieRecommendations;
  late MockGetWatchListStatus mockGetWatchlistStatus;
  late MockSaveWatchlist mockSaveWatchlist;
  late MockRemoveWatchlist mockRemoveWatchlist;
  late MovieDetailBloc movieDetailBloc;

  const tId = 1;

  setUp(() {
    mockGetMovieDetail = MockGetMovieDetail();
    mockGetMovieRecommendations = MockGetMovieRecommendations();
    mockGetWatchlistStatus = MockGetWatchListStatus();
    mockSaveWatchlist = MockSaveWatchlist();
    mockRemoveWatchlist = MockRemoveWatchlist();
    movieDetailBloc = MovieDetailBloc(
      getMovieDetail: mockGetMovieDetail,
      getMovieRecommendations: mockGetMovieRecommendations,
      getWatchListStatus: mockGetWatchlistStatus,
      saveWatchlist: mockSaveWatchlist,
      removeWatchlist: mockRemoveWatchlist,
    );
  });

  final initialState = MovieDetailState.initial();

  test('initial state should be the empty detail state', () {
    expect(movieDetailBloc.state, initialState);
  });

  group('FetchMovieDetail', () {
    blocTest<MovieDetailBloc, MovieDetailState>(
      'should emit Loading then Loaded detail with loaded recommendations',
      build: () {
        when(mockGetMovieDetail.execute(tId))
            .thenAnswer((_) async => Right(testMovieDetail));
        when(mockGetMovieRecommendations.execute(tId))
            .thenAnswer((_) async => Right(testMovieList));
        return movieDetailBloc;
      },
      act: (bloc) => bloc.add(FetchMovieDetail(tId)),
      expect: () => [
        initialState.copyWith(movieDetailState: RequestState.Loading),
        initialState.copyWith(
          movieDetailState: RequestState.Loading,
          recommendationState: RequestState.Loading,
          movieDetail: testMovieDetail,
        ),
        initialState.copyWith(
          movieDetailState: RequestState.Loaded,
          recommendationState: RequestState.Loaded,
          movieDetail: testMovieDetail,
          movieRecommendations: testMovieList,
        ),
      ],
      verify: (_) {
        verify(mockGetMovieDetail.execute(tId));
        verify(mockGetMovieRecommendations.execute(tId));
      },
    );

    blocTest<MovieDetailBloc, MovieDetailState>(
      'should emit Loading then Error when getting detail fails',
      build: () {
        when(mockGetMovieDetail.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
        when(mockGetMovieRecommendations.execute(tId))
            .thenAnswer((_) async => Right(testMovieList));
        return movieDetailBloc;
      },
      act: (bloc) => bloc.add(FetchMovieDetail(tId)),
      expect: () => [
        initialState.copyWith(movieDetailState: RequestState.Loading),
        initialState.copyWith(
          movieDetailState: RequestState.Error,
          message: 'Server Failure',
        ),
      ],
    );

    blocTest<MovieDetailBloc, MovieDetailState>(
      'should load detail but mark recommendations as Error when they fail',
      build: () {
        when(mockGetMovieDetail.execute(tId))
            .thenAnswer((_) async => Right(testMovieDetail));
        when(mockGetMovieRecommendations.execute(tId))
            .thenAnswer((_) async => Left(ServerFailure('Failed')));
        return movieDetailBloc;
      },
      act: (bloc) => bloc.add(FetchMovieDetail(tId)),
      expect: () => [
        initialState.copyWith(movieDetailState: RequestState.Loading),
        initialState.copyWith(
          movieDetailState: RequestState.Loading,
          recommendationState: RequestState.Loading,
          movieDetail: testMovieDetail,
        ),
        initialState.copyWith(
          movieDetailState: RequestState.Loaded,
          recommendationState: RequestState.Error,
          movieDetail: testMovieDetail,
          message: 'Failed',
        ),
      ],
    );
  });

  group('Watchlist', () {
    blocTest<MovieDetailBloc, MovieDetailState>(
      'AddToWatchlist should emit success message then added status',
      build: () {
        when(mockSaveWatchlist.execute(testMovieDetail)).thenAnswer(
            (_) async => Right(MovieDetailBloc.watchlistAddSuccessMessage));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => true);
        return movieDetailBloc;
      },
      act: (bloc) => bloc.add(AddToWatchlist(testMovieDetail)),
      expect: () => [
        initialState.copyWith(
          watchlistMessage: MovieDetailBloc.watchlistAddSuccessMessage,
        ),
        initialState.copyWith(
          watchlistMessage: MovieDetailBloc.watchlistAddSuccessMessage,
          isAddedToWatchlist: true,
        ),
      ],
      verify: (_) {
        verify(mockSaveWatchlist.execute(testMovieDetail));
        verify(mockGetWatchlistStatus.execute(testMovieDetail.id));
      },
    );

    blocTest<MovieDetailBloc, MovieDetailState>(
      'AddToWatchlist should emit failure message when saving fails',
      build: () {
        when(mockSaveWatchlist.execute(testMovieDetail))
            .thenAnswer((_) async => Left(DatabaseFailure('Failed')));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => false);
        return movieDetailBloc;
      },
      act: (bloc) => bloc.add(AddToWatchlist(testMovieDetail)),
      expect: () => [
        initialState.copyWith(watchlistMessage: 'Failed'),
      ],
    );

    blocTest<MovieDetailBloc, MovieDetailState>(
      'RemoveFromWatchlist should emit success message then removed status',
      build: () {
        when(mockRemoveWatchlist.execute(testMovieDetail)).thenAnswer(
            (_) async => Right(MovieDetailBloc.watchlistRemoveSuccessMessage));
        when(mockGetWatchlistStatus.execute(testMovieDetail.id))
            .thenAnswer((_) async => false);
        return movieDetailBloc;
      },
      seed: () => initialState.copyWith(isAddedToWatchlist: true),
      act: (bloc) => bloc.add(RemoveFromWatchlist(testMovieDetail)),
      expect: () => [
        initialState.copyWith(
          isAddedToWatchlist: true,
          watchlistMessage: MovieDetailBloc.watchlistRemoveSuccessMessage,
        ),
        initialState.copyWith(
          isAddedToWatchlist: false,
          watchlistMessage: MovieDetailBloc.watchlistRemoveSuccessMessage,
        ),
      ],
      verify: (_) {
        verify(mockRemoveWatchlist.execute(testMovieDetail));
        verify(mockGetWatchlistStatus.execute(testMovieDetail.id));
      },
    );

    blocTest<MovieDetailBloc, MovieDetailState>(
      'LoadWatchlistStatus should emit the status returned by the use case',
      build: () {
        when(mockGetWatchlistStatus.execute(tId)).thenAnswer((_) async => true);
        return movieDetailBloc;
      },
      act: (bloc) => bloc.add(LoadWatchlistStatus(tId)),
      expect: () => [
        initialState.copyWith(isAddedToWatchlist: true),
      ],
      verify: (_) {
        verify(mockGetWatchlistStatus.execute(tId));
      },
    );
  });
}
