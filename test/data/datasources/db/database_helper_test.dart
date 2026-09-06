import 'package:ditonton/data/datasources/db/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../dummy_data/dummy_objects.dart';

void main() {
  late DatabaseHelper databaseHelper;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final path = await getDatabasesPath();
    await databaseFactory.deleteDatabase('$path/ditonton.db');
    databaseHelper = DatabaseHelper();
  });

  group('watchlist movies', () {
    tearDown(() async {
      await databaseHelper.removeWatchlist(testMovieTable);
    });

    test('should return id when insert to database is success', () async {
      // act
      final result = await databaseHelper.insertWatchlist(testMovieTable);
      // assert
      expect(result, greaterThan(0));
    });

    test('should return movie map when data is found', () async {
      // arrange
      await databaseHelper.insertWatchlist(testMovieTable);
      // act
      final result = await databaseHelper.getMovieById(testMovieTable.id);
      // assert
      expect(result, isNotNull);
      expect(result!['id'], testMovieTable.id);
      expect(result['title'], testMovieTable.title);
      expect(result['overview'], testMovieTable.overview);
      expect(result['posterPath'], testMovieTable.posterPath);
    });

    test('should return list of watchlist movies after insert', () async {
      // arrange
      await databaseHelper.insertWatchlist(testMovieTable);
      // act
      final result = await databaseHelper.getWatchlistMovies();
      // assert
      expect(result.length, 1);
      expect(result.first['id'], testMovieTable.id);
    });

    test('should remove movie from database and return null after remove',
        () async {
      // arrange
      await databaseHelper.insertWatchlist(testMovieTable);
      // act
      final removeResult = await databaseHelper.removeWatchlist(testMovieTable);
      final result = await databaseHelper.getMovieById(testMovieTable.id);
      // assert
      expect(removeResult, greaterThan(0));
      expect(result, isNull);
    });

    test('should return empty list when there is no watchlist movie', () async {
      // act
      final result = await databaseHelper.getWatchlistMovies();
      // assert
      expect(result, isEmpty);
    });
  });

  group('watchlist tvs', () {
    tearDown(() async {
      await databaseHelper.removeWatchlistTv(testTvTable);
    });

    test('should return id when insert to database is success', () async {
      // act
      final result = await databaseHelper.insertWatchlistTv(testTvTable);
      // assert
      expect(result, greaterThan(0));
    });

    test('should return tv map when data is found', () async {
      // arrange
      await databaseHelper.insertWatchlistTv(testTvTable);
      // act
      final result = await databaseHelper.getTvById(testTvTable.id);
      // assert
      expect(result, isNotNull);
      expect(result!['id'], testTvTable.id);
      expect(result['name'], testTvTable.name);
      expect(result['overview'], testTvTable.overview);
      expect(result['posterPath'], testTvTable.posterPath);
    });

    test('should return list of watchlist tvs after insert', () async {
      // arrange
      await databaseHelper.insertWatchlistTv(testTvTable);
      // act
      final result = await databaseHelper.getWatchlistTvs();
      // assert
      expect(result.length, 1);
      expect(result.first['id'], testTvTable.id);
    });

    test('should remove tv from database and return null after remove',
        () async {
      // arrange
      await databaseHelper.insertWatchlistTv(testTvTable);
      // act
      final removeResult =
          await databaseHelper.removeWatchlistTv(testTvTable);
      final result = await databaseHelper.getTvById(testTvTable.id);
      // assert
      expect(removeResult, greaterThan(0));
      expect(result, isNull);
    });

    test('should return empty list when there is no watchlist tv', () async {
      // act
      final result = await databaseHelper.getWatchlistTvs();
      // assert
      expect(result, isEmpty);
    });
  });

  group('separate watchlist tables', () {
    tearDown(() async {
      await databaseHelper.removeWatchlist(testMovieTable);
      await databaseHelper.removeWatchlistTv(testTvTable);
    });

    test('should keep movie and tv with the same id independent', () async {
      // arrange
      await databaseHelper.insertWatchlist(testMovieTable);
      await databaseHelper.insertWatchlistTv(testTvTable);
      // act
      await databaseHelper.removeWatchlist(testMovieTable);
      final movieResult = await databaseHelper.getMovieById(testMovieTable.id);
      final tvResult = await databaseHelper.getTvById(testTvTable.id);
      // assert
      expect(testMovieTable.id, testTvTable.id);
      expect(movieResult, isNull);
      expect(tvResult, isNotNull);
    });
  });
}
