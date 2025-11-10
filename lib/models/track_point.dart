import 'package:hive/hive.dart';

part 'track_point.g.dart';

@HiveType(typeId: 2)
class TrackPoint extends HiveObject {
  @HiveField(0)
  String tripId;

  @HiveField(1)
  DateTime tsUtc;

  @HiveField(2)
  double lat;

  @HiveField(3)
  double lon;

  @HiveField(4)
  double? alt;

  @HiveField(5)
  double? speed;      // m/s

  @HiveField(6)
  double? headingDeg; // degrees

  TrackPoint({
    required this.tripId,
    required this.tsUtc,
    required this.lat,
    required this.lon,
    this.alt,
    this.speed,
    this.headingDeg,
  });
}
