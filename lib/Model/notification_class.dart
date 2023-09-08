import 'package:firebase_messaging/firebase_messaging.dart';

class MyNotification {
  RemoteMessage message;
  bool isRead;

  MyNotification({required this.message, this.isRead = false});
}
