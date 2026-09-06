import 'dart:convert';

import 'package:ditonton/data/models/genre_model.dart';
import 'package:ditonton/data/models/season_model.dart';
import 'package:ditonton/data/models/tv_detail_model.dart';
import 'package:ditonton/domain/entities/genre.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_detail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../json_reader.dart';

void main() {
  final tSeasonModels = [
    SeasonModel(
      id: 3627,
      name: 'Specials',
      overview: '',
      posterPath: '/kMTcwNRfFKCZ0O2OaBZS0nZ2AIe.jpg',
      seasonNumber: 0,
      episodeCount: 272,
      airDate: '2010-12-05',
    ),
    SeasonModel(
      id: 3624,
      name: 'Season 1',
      overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
      posterPath: '/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg',
      seasonNumber: 1,
      episodeCount: 10,
      airDate: '2011-04-17',
    ),
  ];

  final tTvDetailModel = TvDetailModel(
    adult: false,
    backdropPath: '/aDbLBWLjLhFvKlqcHZLVOEfeIYX.jpg',
    genres: [
      GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'),
      GenreModel(id: 18, name: 'Drama'),
    ],
    id: 1399,
    originalName: 'Game of Thrones',
    overview:
        'Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war.',
    posterPath: '/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
    firstAirDate: '2011-04-17',
    name: 'Game of Thrones',
    numberOfSeasons: 8,
    numberOfEpisodes: 73,
    seasons: tSeasonModels,
    voteAverage: 8.4,
    voteCount: 11504,
  );

  final tTvDetail = TvDetail(
    adult: false,
    backdropPath: '/aDbLBWLjLhFvKlqcHZLVOEfeIYX.jpg',
    genres: [
      Genre(id: 10765, name: 'Sci-Fi & Fantasy'),
      Genre(id: 18, name: 'Drama'),
    ],
    id: 1399,
    originalName: 'Game of Thrones',
    overview:
        'Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war.',
    posterPath: '/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
    firstAirDate: '2011-04-17',
    name: 'Game of Thrones',
    numberOfSeasons: 8,
    numberOfEpisodes: 73,
    seasons: [
      Season(
        id: 3627,
        name: 'Specials',
        overview: '',
        posterPath: '/kMTcwNRfFKCZ0O2OaBZS0nZ2AIe.jpg',
        seasonNumber: 0,
        episodeCount: 272,
        airDate: '2010-12-05',
      ),
      Season(
        id: 3624,
        name: 'Season 1',
        overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
        posterPath: '/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg',
        seasonNumber: 1,
        episodeCount: 10,
        airDate: '2011-04-17',
      ),
    ],
    voteAverage: 8.4,
    voteCount: 11504,
  );

  group('TvDetailModel Tests', () {
    group('fromJson', () {
      test('should return a valid model from JSON', () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(readJson('dummy_data/tv_detail.json'));
        // act
        final result = TvDetailModel.fromJson(jsonMap);
        // assert
        expect(result, tTvDetailModel);
      });

      test('should parse nested genres and seasons', () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(readJson('dummy_data/tv_detail.json'));
        // act
        final result = TvDetailModel.fromJson(jsonMap);
        // assert
        expect(result.genres.length, 2);
        expect(result.genres.first, GenreModel(id: 10765, name: 'Sci-Fi & Fantasy'));
        expect(result.seasons.length, 2);
        expect(result.seasons.last, tSeasonModels.last);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () async {
        // act
        final result = tTvDetailModel.toJson();
        // assert
        final expectedJsonMap = {
          "adult": false,
          "backdrop_path": "/aDbLBWLjLhFvKlqcHZLVOEfeIYX.jpg",
          "genres": [
            {"id": 10765, "name": "Sci-Fi & Fantasy"},
            {"id": 18, "name": "Drama"},
          ],
          "id": 1399,
          "original_name": "Game of Thrones",
          "overview":
              "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war.",
          "poster_path": "/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg",
          "first_air_date": "2011-04-17",
          "name": "Game of Thrones",
          "number_of_seasons": 8,
          "number_of_episodes": 73,
          "seasons": [
            {
              "id": 3627,
              "name": "Specials",
              "overview": "",
              "poster_path": "/kMTcwNRfFKCZ0O2OaBZS0nZ2AIe.jpg",
              "season_number": 0,
              "episode_count": 272,
              "air_date": "2010-12-05",
            },
            {
              "id": 3624,
              "name": "Season 1",
              "overview": "Trouble is brewing in the Seven Kingdoms of Westeros.",
              "poster_path": "/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg",
              "season_number": 1,
              "episode_count": 10,
              "air_date": "2011-04-17",
            },
          ],
          "vote_average": 8.4,
          "vote_count": 11504,
        };
        expect(result, expectedJsonMap);
      });
    });

    group('toEntity', () {
      test('should be a subclass of TvDetail entity', () async {
        // act
        final result = tTvDetailModel.toEntity();
        // assert
        expect(result, tTvDetail);
      });

      test('should map nested genres and seasons to entities', () async {
        // act
        final result = tTvDetailModel.toEntity();
        // assert
        expect(result.genres, isA<List<Genre>>());
        expect(result.seasons, isA<List<Season>>());
        expect(result.genres.first, Genre(id: 10765, name: 'Sci-Fi & Fantasy'));
        expect(result.seasons.last, tTvDetail.seasons.last);
      });
    });
  });
}
