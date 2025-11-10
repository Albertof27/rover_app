import 'package:hive_flutter/hive_flutter.dart';
import 'models/trip.dart';
import 'models/track_point.dart';
import 'repo/trip_repository.dart';
import 'services/trip_recorder.dart';

class AppServices {
  AppServices._();
  static final AppServices I = AppServices._();

  late final TripRepository repo;
  late final TripRecorder recorder;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TripAdapter());
    Hive.registerAdapter(TrackPointAdapter());

    final repo = await TripRepository.init();
    final recorder = TripRecorder(repo);

    I.repo = repo;
    I.recorder = recorder;
  }
}
