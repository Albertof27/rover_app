//this code pulls platform channels apis to allow dart to talk to the andoid side of the process
import 'package:flutter/services.dart';

class NotifyBridge {
  //this line create the channel that allows for notifications
  static const _m = MethodChannel('rover/notify');
  //this will just ask for permissions to have notifications
  static Future<void> requestPermission() =>
    _m.invokeMethod('requestPermission');
  //this line makes the general outline for the notification and then the kotlin side will actually fill out the outline and send it back
  static Future<void> showInstant({required String title, required String body}) =>
    _m.invokeMethod('showInstant', {'title': title, 'body': body});

}