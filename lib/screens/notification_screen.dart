import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../Model/notification_class.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key, required this.notifications})
      : super(key: key);
  final List<MyNotification> notifications;
  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
            itemBuilder: (context, index) {
              final notifications = widget.notifications[index];
              return VisibilityDetector(
                key: ValueKey(
                    '${notifications.message.messageId}'), //
                onVisibilityChanged: (VisibilityInfo info) {
                  var visiblePercentage = info.visibleFraction * 100;
                  if (visiblePercentage == 100) {
                    setState(() {
                      notifications.isRead = true;
                    });
                  }
                  debugPrint(
                      'Widget ${info.key} is ${visiblePercentage}% visible');
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    title: Text(
                        notifications.message.notification!.title.toString()),
                    subtitle: Text(
                        notifications.message.notification!.body.toString()),
                    trailing: CircleAvatar(
                      radius: 5,
                      backgroundColor: notifications.isRead == true
                          ? Colors.grey[400]
                          : Colors.blueAccent,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 12,
              );
            },
            itemCount: widget.notifications.length),
      ),
    );
  }
}
