import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_top_rated_tvs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class TopRatedTvsEvent extends Equatable {
  const TopRatedTvsEvent();

  @override
  List<Object> get props => [];
}

class FetchTopRatedTvs extends TopRatedTvsEvent {}

// ----- State -----

abstract class TopRatedTvsState extends Equatable {
  const TopRatedTvsState();

  @override
  List<Object> get props => [];
}

class TopRatedTvsEmpty extends TopRatedTvsState {}

class TopRatedTvsLoading extends TopRatedTvsState {}

class TopRatedTvsError extends TopRatedTvsState {
  final String message;

  const TopRatedTvsError(this.message);

  @override
  List<Object> get props => [message];
}

class TopRatedTvsHasData extends TopRatedTvsState {
  final List<Tv> result;

  const TopRatedTvsHasData(this.result);

  @override
  List<Object> get props => [result];
}

// ----- Bloc -----

class TopRatedTvsBloc extends Bloc<TopRatedTvsEvent, TopRatedTvsState> {
  final GetTopRatedTvs _getTopRatedTvs;

  TopRatedTvsBloc(this._getTopRatedTvs) : super(TopRatedTvsEmpty()) {
    on<FetchTopRatedTvs>((event, emit) async {
      emit(TopRatedTvsLoading());

      final result = await _getTopRatedTvs.execute();

      result.fold(
        (failure) => emit(TopRatedTvsError(failure.message)),
        (data) => emit(TopRatedTvsHasData(data)),
      );
    });
  }
}
