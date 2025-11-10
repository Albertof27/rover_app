import 'package:hive/hive.dart';

part 'trip.g.dart';

@HiveType(typeId: 1)
class Trip extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime startedAt;

  @HiveField(3)
  DateTime? endedAt;

  @HiveField(4)
  double distanceMeters;

  @HiveField(5)
  int pointCount;

  Trip({
    required this.id,
    required this.name,
    required this.startedAt,
    this.endedAt,
    this.distanceMeters = 0.0,
    this.pointCount = 0,
  });

  bool get isActive => endedAt == null;
}
