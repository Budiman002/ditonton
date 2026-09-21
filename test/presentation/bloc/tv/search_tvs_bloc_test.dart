import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/common/failure.dart';
import 'package:ditonton/domain/usecases/search_tvs.dart';
import 'package:ditonton/presentation/bloc/tv/search_tvs_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../dummy_data/dummy_objects.dart';
import 'search_tvs_bloc_test.mocks.dart';

@GenerateMocks([SearchTvs])
void main() {
  late MockSearchTvs mockSearchTvs;
  late SearchTvsBloc searchTvsBloc;

  const tQuery = 'game of thrones';

  setUp(() {
    mockSearchTvs = MockSearchTvs();
    searchTvsBloc = SearchTvsBloc(mockSearchTvs);
  });

  test('initial state should be empty', () {
    expect(searchTvsBloc.state, SearchTvsEmpty());
  });

  blocTest<SearchTvsBloc, SearchTvsState>(
    'should emit [Loading, HasData] when data is gotten successfully',
    build: () {
      when(mockSearchTvs.execute(tQuery))
          .thenAnswer((_) async => Right(testTvList));
      return searchTvsBloc;
    },
    act: (bloc) => bloc.add(OnQueryChanged(tQuery)),
    expect: () => [
      SearchTvsLoading(),
      SearchTvsHasData(testTvList),
    ],
    verify: (_) {
      verify(mockSearchTvs.execute(tQuery));
    },
  );

  blocTest<SearchTvsBloc, SearchTvsState>(
    'should emit [Loading, Error] when getting data is unsuccessful',
    build: () {
      when(mockSearchTvs.execute(tQuery))
          .thenAnswer((_) async => Left(ServerFailure('Server Failure')));
      return searchTvsBloc;
    },
    act: (bloc) => bloc.add(OnQueryChanged(tQuery)),
    expect: () => [
      SearchTvsLoading(),
      SearchTvsError('Server Failure'),
    ],
    verify: (_) {
      verify(mockSearchTvs.execute(tQuery));
    },
  );
}
