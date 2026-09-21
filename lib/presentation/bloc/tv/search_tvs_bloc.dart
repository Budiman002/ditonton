import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/usecases/search_tvs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ----- Event -----

abstract class SearchTvsEvent extends Equatable {
  const SearchTvsEvent();

  @override
  List<Object> get props => [];
}

class OnQueryChanged extends SearchTvsEvent {
  final String query;

  const OnQueryChanged(this.query);

  @override
  List<Object> get props => [query];
}

// ----- State -----

abstract class SearchTvsState extends Equatable {
  const SearchTvsState();

  @override
  List<Object> get props => [];
}

class SearchTvsEmpty extends SearchTvsState {}

class SearchTvsLoading extends SearchTvsState {}

class SearchTvsError extends SearchTvsState {
  final String message;

  const SearchTvsError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchTvsHasData extends SearchTvsState {
  final List<Tv> result;

  const SearchTvsHasData(this.result);

  @override
  List<Object> get props => [result];
}

// ----- Bloc -----

class SearchTvsBloc extends Bloc<SearchTvsEvent, SearchTvsState> {
  final SearchTvs _searchTvs;

  SearchTvsBloc(this._searchTvs) : super(SearchTvsEmpty()) {
    on<OnQueryChanged>((event, emit) async {
      emit(SearchTvsLoading());

      final result = await _searchTvs.execute(event.query);

      result.fold(
        (failure) => emit(SearchTvsError(failure.message)),
        (data) => emit(SearchTvsHasData(data)),
      );
    });
  }
}
