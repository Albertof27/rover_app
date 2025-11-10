import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/track_point.dart';
import '../repo/trip_repository.dart';

class TripRecorder {
  final TripRepository repo;

  StreamSubscription<Position>? _sub;
  String? _activeTripId;
  DateTime? _lastSavedTs;
  Position? _lastSavedPos;

  // Tuning knobs
  final int minSeconds = 2;     // time throttle
  final double minMeters = 5.0; // distance throttle
  final double maxHdopMeters = 50.0; // use 'accuracy' as a proxy

  TripRecorder(this.repo);

  bool get isRecording => _activeTripId != null;

  Future<bool> _ensurePermissions() async {
    LocationPermission p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.deniedForever || p == LocationPermission.denied) {
      return false;
    }
    final enabled = await Geolocator.isLocationServiceEnabled();
    return enabled;
  }

  Future<String?> start(String name) async {
    if (!await _ensurePermissions()) return null;

    final trip = await repo.createTrip(name);
    _activeTripId = trip.id;
    _lastSavedTs = null;
    _lastSavedPos = null;

    final stream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0, // we handle throttle ourselves
        intervalDuration: Duration(seconds: 2),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Rover logging in background',
            notificationText: 'Trip recording is active.',
            enableWakeLock: true,
          ),
        ),
      
    );

    _sub = stream.listen((pos) async {
      if (pos.accuracy.isNaN || pos.accuracy > maxHdopMeters) return;

      final now = DateTime.now().toUtc();

      final timeOk = _lastSavedTs == null ||
          now.difference(_lastSavedTs!).inSeconds >= minSeconds;

      final distOk = _lastSavedPos == null ||
          Geolocator.distanceBetween(
                  _lastSavedPos!.latitude,
                  _lastSavedPos!.longitude,
                  pos.latitude,
                  pos.longitude) >= minMeters;

      if (timeOk && distOk && _activeTripId != null) {
        final tp = TrackPoint(
          tripId: _activeTripId!,
          tsUtc: now,
          lat: pos.latitude,
          lon: pos.longitude,
          alt: pos.altitude,
          speed: pos.speed,
          headingDeg: pos.heading,
        );
        await repo.insertPoint(tp);
        _lastSavedTs = now;
        _lastSavedPos = pos;
      }
    });

    return _activeTripId;
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    final id = _activeTripId;
    _activeTripId = null;
    if (id != null) {
      await repo.finalizeTrip(id, simplifyToleranceM: 5);
    }
  }
}
