import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/movie.dart';
import 'package:ditonton/domain/entities/movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_detail.dart';
import 'package:ditonton/domain/usecases/get_movie_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist.dart';
import 'package:ditonton/domain/usecases/save_watchlist.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchMovieDetail extends MovieDetailEvent {
  final int id;

  const FetchMovieDetail(this.id);

  @override
  List<Object> get props => [id];
}

class AddToWatchlist extends MovieDetailEvent {
  final MovieDetail movie;

  const AddToWatchlist(this.movie);

  @override
  List<Object> get props => [movie];
}

class RemoveFromWatchlist extends MovieDetailEvent {
  final MovieDetail movie;

  const RemoveFromWatchlist(this.movie);

  @override
  List<Object> get props => [movie];
}

class LoadWatchlistStatus extends MovieDetailEvent {
  final int id;

  const LoadWatchlistStatus(this.id);

  @override
  List<Object> get props => [id];
}

// ----- State -----

class MovieDetailState extends Equatable {
  final MovieDetail? movieDetail;
  final RequestState movieDetailState;
  final List<Movie> movieRecommendations;
  final RequestState recommendationState;
  final String message;
  final bool isAddedToWatchlist;
  final String watchlistMessage;

  const MovieDetailState({
    required this.movieDetail,
    required this.movieDetailState,
    required this.movieRecommendations,
    required this.recommendationState,
    required this.message,
    required this.isAddedToWatchlist,
    required this.watchlistMessage,
  });

  factory MovieDetailState.initial() => const MovieDetailState(
        movieDetail: null,
        movieDetailState: RequestState.Empty,
        movieRecommendations: [],
        recommendationState: RequestState.Empty,
        message: '',
        isAddedToWatchlist: false,
        watchlistMessage: '',
      );

  MovieDetailState copyWith({
    MovieDetail? movieDetail,
    RequestState? movieDetailState,
    List<Movie>? movieRecommendations,
    RequestState? recommendationState,
    String? message,
    bool? isAddedToWatchlist,
    String? watchlistMessage,
  }) {
    return MovieDetailState(
      movieDetail: movieDetail ?? this.movieDetail,
      movieDetailState: movieDetailState ?? this.movieDetailState,
      movieRecommendations: movieRecommendations ?? this.movieRecommendations,
      recommendationState: recommendationState ?? this.recommendationState,
      message: message ?? this.message,
      isAddedToWatchlist: isAddedToWatchlist ?? this.isAddedToWatchlist,
      watchlistMessage: watchlistMessage ?? this.watchlistMessage,
    );
  }

  @override
  List<Object?> get props => [
        movieDetail,
        movieDetailState,
        movieRecommendations,
        recommendationState,
        message,
        isAddedToWatchlist,
        watchlistMessage,
      ];
}

// ----- Bloc -----

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetMovieDetail getMovieDetail;
  final GetMovieRecommendations getMovieRecommendations;
  final GetWatchListStatus getWatchListStatus;
  final SaveWatchlist saveWatchlist;
  final RemoveWatchlist removeWatchlist;

  MovieDetailBloc({
    required this.getMovieDetail,
    required this.getMovieRecommendations,
    required this.getWatchListStatus,
    required this.saveWatchlist,
    required this.removeWatchlist,
  }) : super(MovieDetailState.initial()) {
    on<FetchMovieDetail>(_onFetchMovieDetail);
    on<AddToWatchlist>(_onAddToWatchlist);
    on<RemoveFromWatchlist>(_onRemoveFromWatchlist);
    on<LoadWatchlistStatus>(_onLoadWatchlistStatus);
  }

  Future<void> _onFetchMovieDetail(
    FetchMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(state.copyWith(movieDetailState: RequestState.Loading));

    final detailResult = await getMovieDetail.execute(event.id);
    final recommendationResult =
        await getMovieRecommendations.execute(event.id);

    detailResult.fold(
      (failure) {
        emit(state.copyWith(
          movieDetailState: RequestState.Error,
          message: failure.message,
        ));
      },
      (movie) {
        // mirrors the notifier: recommendations go to Loading and the detail
        // lands before the recommendation result is folded in.
        emit(state.copyWith(
          recommendationState: RequestState.Loading,
          movieDetail: movie,
        ));

        recommendationResult.fold(
          (failure) {
            emit(state.copyWith(
              movieDetailState: RequestState.Loaded,
              recommendationState: RequestState.Error,
              message: failure.message,
            ));
          },
          (movies) {
            emit(state.copyWith(
              movieDetailState: RequestState.Loaded,
              recommendationState: RequestState.Loaded,
              movieRecommendations: movies,
            ));
          },
        );
      },
    );
  }

  Future<void> _onAddToWatchlist(
    AddToWatchlist event,
    Emitter<MovieDetailState> emit,
  ) async {
    final result = await saveWatchlist.execute(event.movie);

    result.fold(
      (failure) => emit(state.copyWith(watchlistMessage: failure.message)),
      (successMessage) =>
          emit(state.copyWith(watchlistMessage: successMessage)),
    );

    add(LoadWatchlistStatus(event.movie.id));
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlist event,
    Emitter<MovieDetailState> emit,
  ) async {
    final result = await removeWatchlist.execute(event.movie);

    result.fold(
      (failure) => emit(state.copyWith(watchlistMessage: failure.message)),
      (successMessage) =>
          emit(state.copyWith(watchlistMessage: successMessage)),
    );

    add(LoadWatchlistStatus(event.movie.id));
  }

  Future<void> _onLoadWatchlistStatus(
    LoadWatchlistStatus event,
    Emitter<MovieDetailState> emit,
  ) async {
    final result = await getWatchListStatus.execute(event.id);
    emit(state.copyWith(isAddedToWatchlist: result));
  }
}
