import 'package:equatable/equatable.dart';

class Season extends Equatable {
  Season({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.seasonNumber,
    required this.episodeCount,
    required this.airDate,
  });

  final int id;
  final String? name;
  final String? overview;
  final String? posterPath;
  final int seasonNumber;
  final int episodeCount;
  final String? airDate;

  @override
  List<Object?> get props => [
        id,
        name,
        overview,
        posterPath,
        seasonNumber,
        episodeCount,
        airDate,
      ];
}
