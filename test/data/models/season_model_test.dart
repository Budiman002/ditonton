import 'dart:convert';

import 'package:ditonton/data/models/season_model.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../json_reader.dart';

void main() {
  final tSeasonModel = SeasonModel(
    id: 3624,
    name: 'Season 1',
    overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
    posterPath: '/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg',
    seasonNumber: 1,
    episodeCount: 10,
    airDate: '2011-04-17',
  );

  final tSeason = Season(
    id: 3624,
    name: 'Season 1',
    overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
    posterPath: '/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg',
    seasonNumber: 1,
    episodeCount: 10,
    airDate: '2011-04-17',
  );

  final tSeasonJson = {
    "id": 3624,
    "name": "Season 1",
    "overview": "Trouble is brewing in the Seven Kingdoms of Westeros.",
    "poster_path": "/zwaj4egrhnXOBIit1tyb4Sbt3KP.jpg",
    "season_number": 1,
    "episode_count": 10,
    "air_date": "2011-04-17",
  };

  group('SeasonModel Tests', () {
    group('fromJson', () {
      test('should return a valid model from JSON', () async {
        // arrange
        final Map<String, dynamic> jsonMap =
            json.decode(readJson('dummy_data/tv_detail.json'));
        // act
        final result = SeasonModel.fromJson(jsonMap['seasons'][1]);
        // assert
        expect(result, tSeasonModel);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () async {
        // act
        final result = tSeasonModel.toJson();
        // assert
        expect(result, tSeasonJson);
      });
    });

    group('toEntity', () {
      test('should be a subclass of Season entity', () async {
        // act
        final result = tSeasonModel.toEntity();
        // assert
        expect(result, tSeason);
      });
    });
  });
}
