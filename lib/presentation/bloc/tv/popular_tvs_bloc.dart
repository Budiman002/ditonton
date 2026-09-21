import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_popular_tvs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class PopularTvsEvent extends Equatable {
  const PopularTvsEvent();

  @override
  List<Object> get props => [];
}

class FetchPopularTvs extends PopularTvsEvent {}

// ----- State -----

abstract class PopularTvsState extends Equatable {
  const PopularTvsState();

  @override
  List<Object> get props => [];
}

class PopularTvsEmpty extends PopularTvsState {}

class PopularTvsLoading extends PopularTvsState {}

class PopularTvsError extends PopularTvsState {
  final String message;

  const PopularTvsError(this.message);

  @override
  List<Object> get props => [message];
}

class PopularTvsHasData extends PopularTvsState {
  final List<Tv> result;

  const PopularTvsHasData(this.result);

  @override
  List<Object> get props => [result];
}

// ----- Bloc -----

class PopularTvsBloc extends Bloc<PopularTvsEvent, PopularTvsState> {
  final GetPopularTvs _getPopularTvs;

  PopularTvsBloc(this._getPopularTvs) : super(PopularTvsEmpty()) {
    on<FetchPopularTvs>((event, emit) async {
      emit(PopularTvsLoading());

      final result = await _getPopularTvs.execute();

      result.fold(
        (failure) => emit(PopularTvsError(failure.message)),
        (data) => emit(PopularTvsHasData(data)),
      );
    });
  }
}
