import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ble_controller.dart';

final bleControllerProvider = Provider.autoDispose<BleController>((ref) {
  final ctrl = BleController(ref);
  ref.onDispose(ctrl.dispose);
  return ctrl;
});
