import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_watchlist_tvs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class WatchlistTvsEvent extends Equatable {
  const WatchlistTvsEvent();

  @override
  List<Object> get props => [];
}

class FetchWatchlistTvs extends WatchlistTvsEvent {}

// ----- State -----

abstract class WatchlistTvsState extends Equatable {
  const WatchlistTvsState();

  @override
  List<Object> get props => [];
}

class WatchlistTvsEmpty extends WatchlistTvsState {}

class WatchlistTvsLoading extends WatchlistTvsState {}

class WatchlistTvsError extends WatchlistTvsState {
  final String message;

  const WatchlistTvsError(this.message);

  @override
  List<Object> get props => [message];
}

class WatchlistTvsHasData extends WatchlistTvsState {
  final List<Tv> result;

  const WatchlistTvsHasData(this.result);

  @override
  List<Object> get props => [result];
}

// ----- Bloc -----

class WatchlistTvsBloc extends Bloc<WatchlistTvsEvent, WatchlistTvsState> {
  final GetWatchlistTvs _getWatchlistTvs;

  WatchlistTvsBloc(this._getWatchlistTvs) : super(WatchlistTvsEmpty()) {
    on<FetchWatchlistTvs>((event, emit) async {
      emit(WatchlistTvsLoading());

      final result = await _getWatchlistTvs.execute();

      result.fold(
        (failure) => emit(WatchlistTvsError(failure.message)),
        (data) => emit(WatchlistTvsHasData(data)),
      );
    });
  }
}
