import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/get_on_the_air_tvs.dart';
import 'package:ditonton/presentation/bloc/tv/on_the_air_tvs_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../dummy_data/dummy_objects.dart';
import 'on_the_air_tvs_bloc_test.mocks.dart';

@GenerateMocks([GetOnTheAirTvs])
void main() {
  late MockGetOnTheAirTvs mockGetOnTheAirTvs;
  late OnTheAirTvsBloc onTheAirTvsBloc;

  setUp(() {
    mockGetOnTheAirTvs = MockGetOnTheAirTvs();
    onTheAirTvsBloc = OnTheAirTvsBloc(mockGetOnTheAirTvs);
  });

  test('initial state should be empty', () {
    expect(onTheAirTvsBloc.state, OnTheAirTvsEmpty());
  });

  blocTest<OnTheAirTvsBloc, OnTheAirTvsState>(
    'should emit [Loading, HasData] when data is gotten successfully',
    build: () {
      when(mockGetOnTheAirTvs.execute())
          .thenAnswer((_) async => Right(testTvList));
      return onTheAirTvsBloc;
    },
    act: (bloc) => bloc.add(FetchOnTheAirTvs()),
    expect: () => [
      OnTheAirTvsLoading(),
      OnTheAirTvsHasData(testTvList),
    ],
    verify: (_) {
      verify(mockGetOnTheAirTvs.execute());
    },
  );

  blocTest<OnTheAirTvsBloc, OnTheAirTvsState>(
    'should emit [Loading, Error] when getting data is unsuccessful',
    build: () {
      when(mockGetOnTheAirTvs.execute())
          .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
      return onTheAirTvsBloc;
    },
    act: (bloc) => bloc.add(FetchOnTheAirTvs()),
    expect: () => [
      OnTheAirTvsLoading(),
      OnTheAirTvsError('Server Failure'),
    ],
    verify: (_) {
      verify(mockGetOnTheAirTvs.execute());
    },
  );
}
