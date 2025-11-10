import 'dart:math';
import '../models/track_point.dart';

const _earthRadius = 6371000.0; // meters

double haversine(double lat1, double lon1, double lat2, double lon2) {
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return _earthRadius * c;
}

double _deg2rad(double d) => d * pi / 180.0;

/// Douglas–Peucker polyline simplification (lat/lon in degrees).
List<TrackPoint> simplifyDouglasPeucker(List<TrackPoint> pts, double tolMeters) {
  if (pts.length < 3) return pts;
  final keep = List<bool>.filled(pts.length, false);
  keep[0] = true;
  keep[pts.length - 1] = true;

  void _dp(int start, int end) {
    if (end <= start + 1) return;
    double maxDist = -1;
    int index = -1;
    for (int i = start + 1; i < end; i++) {
      final d = _perpDistance(pts[i], pts[start], pts[end]);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (maxDist > tolMeters) {
      keep[index] = true;
      _dp(start, index);
      _dp(index, end);
    }
  }

  _dp(0, pts.length - 1);
  final out = <TrackPoint>[];
  for (int i = 0; i < pts.length; i++) {
    if (keep[i]) out.add(pts[i]);
  }
  return out;
}

double _perpDistance(TrackPoint p, TrackPoint a, TrackPoint b) {
  // approximate by projecting in meters using local scale near 'a'
  final latScale = pi * _earthRadius / 180.0;
  final lonScale = latScale * cos(a.lat * pi / 180.0);

  final ax = (a.lon) * lonScale;
  final ay = (a.lat) * latScale;
  final bx = (b.lon) * lonScale;
  final by = (b.lat) * latScale;
  final px = (p.lon) * lonScale;
  final py = (p.lat) * latScale;

  final dx = bx - ax;
  final dy = by - ay;
  if (dx == 0 && dy == 0) return sqrt(pow(px - ax, 2) + pow(py - ay, 2));

  final numerator = (dx * (ay - py) - (ax - px) * dy).abs();
  final denominator = sqrt(dx * dx + dy * dy);
  return numerator / denominator;

  
}
String _xmlEscape(String s) =>
  s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

String toGpx(String name, List<TrackPoint> pts) {
  final buf = StringBuffer();
  buf.writeln('<?xml version="1.0" encoding="UTF-8"?>');
  buf.writeln('<gpx version="1.1" creator="RoverApp">');
  buf.writeln('<trk><name>${_xmlEscape(name)}</name><trkseg>');
  for (final p in pts) {
    buf.writeln(
        '<trkpt lat="${p.lat}" lon="${p.lon}"><time>${p.tsUtc.toIso8601String()}</time></trkpt>');
  }
  buf.writeln('</trkseg></trk></gpx>');
  return buf.toString();
}


