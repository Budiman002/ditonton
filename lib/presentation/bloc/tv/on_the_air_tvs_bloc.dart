import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/get_on_the_air_tvs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class OnTheAirTvsEvent extends Equatable {
  const OnTheAirTvsEvent();

  @override
  List<Object> get props => [];
}

class FetchOnTheAirTvs extends OnTheAirTvsEvent {}

// ----- State -----

abstract class OnTheAirTvsState extends Equatable {
  const OnTheAirTvsState();

  @override
  List<Object> get props => [];
}

class OnTheAirTvsEmpty extends OnTheAirTvsState {}

class OnTheAirTvsLoading extends OnTheAirTvsState {}

class OnTheAirTvsError extends OnTheAirTvsState {
  final String message;

  const OnTheAirTvsError(this.message);

  @override
  List<Object> get props => [message];
}

class OnTheAirTvsHasData extends OnTheAirTvsState {
  final List<Tv> result;

  const OnTheAirTvsHasData(this.result);

  @override
  List<Object> get props => [result];
}

// ----- Bloc -----

class OnTheAirTvsBloc extends Bloc<OnTheAirTvsEvent, OnTheAirTvsState> {
  final GetOnTheAirTvs _getOnTheAirTvs;

  OnTheAirTvsBloc(this._getOnTheAirTvs) : super(OnTheAirTvsEmpty()) {
    on<FetchOnTheAirTvs>((event, emit) async {
      emit(OnTheAirTvsLoading());

      final result = await _getOnTheAirTvs.execute();

      result.fold(
        (failure) => emit(OnTheAirTvsError(failure.message)),
        (data) => emit(OnTheAirTvsHasData(data)),
      );
    });
  }
}
