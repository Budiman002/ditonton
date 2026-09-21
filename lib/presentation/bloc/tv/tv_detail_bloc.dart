import 'package:ditonton/common/state_enum.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/entities/tv_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_detail.dart';
import 'package:ditonton/domain/usecases/get_tv_recommendations.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tv_status.dart';
import 'package:ditonton/domain/usecases/remove_watchlist_tv.dart';
import 'package:ditonton/domain/usecases/save_watchlist_tv.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class TvDetailEvent extends Equatable {
  const TvDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchTvDetail extends TvDetailEvent {
  final int id;

  const FetchTvDetail(this.id);

  @override
  List<Object> get props => [id];
}

class AddToWatchlist extends TvDetailEvent {
  final TvDetail tv;

  const AddToWatchlist(this.tv);

  @override
  List<Object> get props => [tv];
}

class RemoveFromWatchlist extends TvDetailEvent {
  final TvDetail tv;

  const RemoveFromWatchlist(this.tv);

  @override
  List<Object> get props => [tv];
}

class LoadWatchlistStatus extends TvDetailEvent {
  final int id;

  const LoadWatchlistStatus(this.id);

  @override
  List<Object> get props => [id];
}

// ----- State -----

class TvDetailState extends Equatable {
  final TvDetail? tvDetail;
  final RequestState tvDetailState;
  final List<Tv> tvRecommendations;
  final RequestState recommendationState;
  final String message;
  final bool isAddedToWatchlist;
  final String watchlistMessage;

  const TvDetailState({
    required this.tvDetail,
    required this.tvDetailState,
    required this.tvRecommendations,
    required this.recommendationState,
    required this.message,
    required this.isAddedToWatchlist,
    required this.watchlistMessage,
  });

  factory TvDetailState.initial() => const TvDetailState(
        tvDetail: null,
        tvDetailState: RequestState.Empty,
        tvRecommendations: [],
        recommendationState: RequestState.Empty,
        message: '',
        isAddedToWatchlist: false,
        watchlistMessage: '',
      );

  TvDetailState copyWith({
    TvDetail? tvDetail,
    RequestState? tvDetailState,
    List<Tv>? tvRecommendations,
    RequestState? recommendationState,
    String? message,
    bool? isAddedToWatchlist,
    String? watchlistMessage,
  }) {
    return TvDetailState(
      tvDetail: tvDetail ?? this.tvDetail,
      tvDetailState: tvDetailState ?? this.tvDetailState,
      tvRecommendations: tvRecommendations ?? this.tvRecommendations,
      recommendationState: recommendationState ?? this.recommendationState,
      message: message ?? this.message,
      isAddedToWatchlist: isAddedToWatchlist ?? this.isAddedToWatchlist,
      watchlistMessage: watchlistMessage ?? this.watchlistMessage,
    );
  }

  @override
  List<Object?> get props => [
        tvDetail,
        tvDetailState,
        tvRecommendations,
        recommendationState,
        message,
        isAddedToWatchlist,
        watchlistMessage,
      ];
}

// ----- Bloc -----

class TvDetailBloc extends Bloc<TvDetailEvent, TvDetailState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetTvDetail getTvDetail;
  final GetTvRecommendations getTvRecommendations;
  final GetWatchListTvStatus getWatchListTvStatus;
  final SaveWatchlistTv saveWatchlistTv;
  final RemoveWatchlistTv removeWatchlistTv;

  TvDetailBloc({
    required this.getTvDetail,
    required this.getTvRecommendations,
    required this.getWatchListTvStatus,
    required this.saveWatchlistTv,
    required this.removeWatchlistTv,
  }) : super(TvDetailState.initial()) {
    on<FetchTvDetail>(_onFetchTvDetail);
    on<AddToWatchlist>(_onAddToWatchlist);
    on<RemoveFromWatchlist>(_onRemoveFromWatchlist);
    on<LoadWatchlistStatus>(_onLoadWatchlistStatus);
  }

  Future<void> _onFetchTvDetail(
    FetchTvDetail event,
    Emitter<TvDetailState> emit,
  ) async {
    emit(state.copyWith(tvDetailState: RequestState.Loading));

    final detailResult = await getTvDetail.execute(event.id);
    final recommendationResult = await getTvRecommendations.execute(event.id);

    detailResult.fold(
      (failure) {
        emit(state.copyWith(
          tvDetailState: RequestState.Error,
          message: failure.message,
        ));
      },
      (tv) {
        // mirrors the notifier: recommendations go to Loading and the detail
        // lands before the recommendation result is folded in.
        emit(state.copyWith(
          recommendationState: RequestState.Loading,
          tvDetail: tv,
        ));

        recommendationResult.fold(
          (failure) {
            emit(state.copyWith(
              tvDetailState: RequestState.Loaded,
              recommendationState: RequestState.Error,
              message: failure.message,
            ));
          },
          (tvs) {
            emit(state.copyWith(
              tvDetailState: RequestState.Loaded,
              recommendationState: RequestState.Loaded,
              tvRecommendations: tvs,
            ));
          },
        );
      },
    );
  }

  Future<void> _onAddToWatchlist(
    AddToWatchlist event,
    Emitter<TvDetailState> emit,
  ) async {
    final result = await saveWatchlistTv.execute(event.tv);

    result.fold(
      (failure) => emit(state.copyWith(watchlistMessage: failure.message)),
      (successMessage) =>
          emit(state.copyWith(watchlistMessage: successMessage)),
    );

    add(LoadWatchlistStatus(event.tv.id));
  }

  Future<void> _onRemoveFromWatchlist(
    RemoveFromWatchlist event,
    Emitter<TvDetailState> emit,
  ) async {
    final result = await removeWatchlistTv.execute(event.tv);

    result.fold(
      (failure) => emit(state.copyWith(watchlistMessage: failure.message)),
      (successMessage) =>
          emit(state.copyWith(watchlistMessage: successMessage)),
    );

    add(LoadWatchlistStatus(event.tv.id));
  }

  Future<void> _onLoadWatchlistStatus(
    LoadWatchlistStatus event,
    Emitter<TvDetailState> emit,
  ) async {
    final result = await getWatchListTvStatus.execute(event.id);
    emit(state.copyWith(isAddedToWatchlist: result));
  }
}
