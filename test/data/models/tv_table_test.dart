import 'package:ditonton/data/models/tv_table.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv.dart';
import 'package:ditonton/domain/entities/tv_detail.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tTvTable = TvTable(
    id: 1,
    name: 'name',
    posterPath: 'posterPath',
    overview: 'overview',
  );

  final tTvDetail = TvDetail(
    adult: false,
    backdropPath: 'backdropPath',
    genres: [Genre(id: 1, name: 'Action')],
    id: 1,
    originalName: 'originalName',
    overview: 'overview',
    posterPath: 'posterPath',
    firstAirDate: 'firstAirDate',
    name: 'name',
    numberOfSeasons: 1,
    numberOfEpisodes: 10,
    seasons: [
      Season(
        id: 1,
        name: 'Season 1',
        overview: 'overview',
        posterPath: 'posterPath',
        seasonNumber: 1,
        episodeCount: 10,
        airDate: 'airDate',
      ),
    ],
    voteAverage: 1,
    voteCount: 1,
  );

  final tTvMap = {
    'id': 1,
    'name': 'name',
    'posterPath': 'posterPath',
    'overview': 'overview',
  };

  final tWatchlistTv = Tv.watchlist(
    id: 1,
    name: 'name',
    posterPath: 'posterPath',
    overview: 'overview',
  );

  group('TvTable Tests', () {
    group('fromEntity', () {
      test('should return a valid table from TvDetail entity', () async {
        // act
        final result = TvTable.fromEntity(tTvDetail);
        // assert
        expect(result, tTvTable);
      });
    });

    group('fromMap', () {
      test('should return a valid table from a database map', () async {
        // act
        final result = TvTable.fromMap(tTvMap);
        // assert
        expect(result, tTvTable);
      });
    });

    group('toJson', () {
      test('should return a map containing proper data', () async {
        // act
        final result = tTvTable.toJson();
        // assert
        expect(result, tTvMap);
      });
    });

    group('toEntity', () {
      test('should return a watchlist Tv entity', () async {
        // act
        final result = tTvTable.toEntity();
        // assert
        expect(result, tWatchlistTv);
      });
    });
  });
}
