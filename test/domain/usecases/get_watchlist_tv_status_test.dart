import 'package:ditonton/domain/usecases/get_watchlist_tv_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetWatchListTvStatus usecase;
  late MockTvRepository mockTvRepository;

  setUp(() {
    mockTvRepository = MockTvRepository();
    usecase = GetWatchListTvStatus(mockTvRepository);
  });

  final tId = 1;

  group('GetWatchListTvStatus Tests', () {
    group('execute', () {
      test('should get watchlist status from the repository', () async {
        // arrange
        when(mockTvRepository.isAddedToWatchlist(tId))
            .thenAnswer((_) async => true);
        // act
        final result = await usecase.execute(tId);
        // assert
        expect(result, true);
      });
    });
  });
}
