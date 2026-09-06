import 'dart:convert';

import 'package:ditonton/data/models/tv_model.dart';
import 'package:ditonton/data/models/tv_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../json_reader.dart';

void main() {
  final tTvModel = TvModel(
    adult: false,
    backdropPath: '/aDbLBWLjLhFvKlqcHZLVOEfeIYX.jpg',
    genreIds: [18, 10765],
    id: 1399,
    originalName: 'Game of Thrones',
    overview:
        'Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war.',
    popularity: 369.594,
    posterPath: '/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',
    firstAirDate: '2011-04-17',
    name: 'Game of Thrones',
    voteAverage: 8.4,
    voteCount: 11504,
  );

  group('TvResponse Tests', () {
    group('fromJson', () {
      test('should return a valid model from JSON', () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(readJson('dummy_data/tv_popular.json'));
        // act
        final result = TvResponse.fromJson(jsonMap);
        // assert
        expect(result.tvList.length, 2);
        expect(result.tvList.first, tTvModel);
      });

      test('should drop items with null poster path', () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(readJson('dummy_data/search_tv.json'));
        // act
        final result = TvResponse.fromJson(jsonMap);
        // assert
        expect((jsonMap['results'] as List).length, 3);
        expect(result.tvList.length, 2);
        expect(result.tvList.every((element) => element.posterPath != null),
            true);
        expect(result.tvList.map((element) => element.id).toList(),
            [1399, 94997]);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () async {
        // arrange
        final tTvResponse = TvResponse(tvList: [tTvModel]);
        // act
        final result = tTvResponse.toJson();
        // assert
        final expectedJsonMap = {
          "results": [
            {
              "adult": false,
              "backdrop_path": "/aDbLBWLjLhFvKlqcHZLVOEfeIYX.jpg",
              "genre_ids": [18, 10765],
              "id": 1399,
              "original_name": "Game of Thrones",
              "overview":
                  "Seven noble families fight for control of the mythical land of Westeros. Friction between the houses leads to full-scale war.",
              "popularity": 369.594,
              "poster_path": "/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg",
              "first_air_date": "2011-04-17",
              "name": "Game of Thrones",
              "vote_average": 8.4,
              "vote_count": 11504,
            },
          ],
        };
        expect(result, expectedJsonMap);
      });
    });

    group('props', () {
      test('should be equal when the tv list is the same', () async {
        // act
        final first = TvResponse(tvList: [tTvModel]);
        final second = TvResponse(tvList: [tTvModel]);
        // assert
        expect(first, second);
        expect(first.props, [
          [tTvModel]
        ]);
      });
    });
  });
}
