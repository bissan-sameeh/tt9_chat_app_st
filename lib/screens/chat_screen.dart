import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tt9_chat_app_st/screens/notification_screen.dart';
import 'package:tt9_chat_app_st/screens/welcome_screen.dart';

import '../Model/notification_class.dart';
import '../constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  static const id = "/ChatScreen";

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  Timer? _timer;

  List<MyNotification> notifications =
      []; //changed from remote message to notification class
  User? user;
  bool alreadyUser = false;
  TextEditingController messageController = TextEditingController();

  void getUser() {
    user = _auth.currentUser;
    if (user != null) {
      print("Current user : ${user!.email}");
    }
  }

  void getNotifications() {
    FirebaseMessaging.onMessage.listen((event) {
      //message that get from firebase and we listening always .
      // print("Got a message while in the foreground");
      // print("message data : ${event.data}");
      if (event.notification != null) {
        setState(() {
          notifications.add(MyNotification(
              message:
                  event)); //instead we pass message we pass all the object to notification screen
        });
        print(
            "message also contained a notification : ${event.notification!.title}");
      }
    });
  }

  // void getMessages() {
  //   db.collection('messages').get().then((value) {//كل دوك عبارة عن ليستة وفي كل ليستة مجموعة من الليستات
  //     final docs = value.docs;
  //     for (var message in docs) { // هيدخل عكل ليستة وهيلف على الليستات يلي جواهم
  //       print(message.data()); //هيجيب الداتا على شكل ماب
  //     }
  //   });
  // }

  removeTyper() async {
    await db.collection("typing").doc(user?.email).delete();
  }
  //
  // Future<void> streamMessages() async {
  //   await for (var messages in db.collection("messages").snapshots()) {
  //     //هيدخل على الكولكشن تبع المسجيز وهيجيب التحديثات يلي بال  docs خط مباشر
  //     for (var message in messages.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    setData();
    getUser();
    getNotifications();
    super.initState();
  }

  int unreadNotifications() {
    int count = 0;
    for (var item in notifications) {
      if (!item.isRead) {
        count++;
      }
    }
    return count;
  }

  void setData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("alreadyUser", true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          const SizedBox(
            width: 12,
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(
                        notifications: notifications,
                      ),
                    )).then((value) {
                  setState(() {
                    unreadNotifications();
                  });

                  // notifications.clear()
                });
              },
              icon: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 30,
                  ),
                  Positioned(
                    top: -1, // Set this to 0
                    left: -2,
                    child: unreadNotifications() > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text("${unreadNotifications()}"),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              )),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                //Implement logout functionality
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                // prefs.remove("user");
                prefs.remove("alreadyUser");
                final GoogleSignIn googleSignIn = GoogleSignIn();
                await googleSignIn.signOut(); // Sign out from Google account
                _auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, WelcomeScreen.id, (route) => false);
                }
              }),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('⚡️Chat'),
            StreamBuilder(
              stream: db.collection("typing").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final typers = snapshot.data!.docs;
                  String names = '';
                  for (var item in typers) {
                    if (user!.email != item.get("email")) {
                      if (names.isNotEmpty) {
                        names = '$names , ${item.get("email")}';
                      } else {
                        names = item.get("email");
                      }
                    }
                  }
                  if (names.isNotEmpty) {
                    names = "$names Typing";
                  }
                  return SingleChildScrollView(
                    child: names.isNotEmpty
                        ? Text(
                            "$names", //${snapshot.data!.docs.first.get("email")} typing
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        : SizedBox.shrink(),
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            removeTyper();
            SystemChannels.platform.invokeMethod("SystemNavigator.pop");
            return false;
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(
                height: 24,
              ),
              StreamBuilder(
                /// فتح خط اتصال مع الداتا بيز بشكل مباشر والتحديث بشكل مستمر بدل الريفرش
                stream: db
                    .collection("messages")
                    .orderBy("time", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages =
                        snapshot.data?.docs; //اللي جوا الكوليكشن هاتلي المسجات
                    return Expanded(
                      child: ListView.separated(
                          reverse: true,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return bubbleMessage(
                                isMe: user?.email ==
                                    messages![index].data()['sender'],
                                messages: messages![index].data()['text'],
                                sender: messages![index].data()['sender']);
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(
                              height: 4,
                            );
                          },
                          itemCount: snapshot.data!.size),
                    );
                  }
                  return Text("loading...");
                },
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        onChanged: (value) {
                          print("1111");

                          //Do something with the user input.
                          if (_timer?.isActive ?? false) _timer!.cancel();
                          _timer = Timer(Duration(milliseconds: 500), () {
                            print("2222");
                            if (user?.email != null) {
                              db
                                  .collection("typing")
                                  .doc(user!.email)
                                  .set({"email": user?.email});
                            }
                          });

                          if (value == '' || value == null || value.isEmpty) {
                            removeTyper();
                          }
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (messageController.text != null &&
                            messageController.text.isNotEmpty) {
                          db.collection("messages").add({
                            "text": messageController.text,
                            "sender": user!.email,
                            "time": DateTime.now()
                          }).then((value) {
                            messageController.clear();
                            removeTyper();
                          }).catchError((err) {
                            print(err);
                          });
                        }
                        //Implement send functionality.
                      },
                      child: const Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class bubbleMessage extends StatelessWidget {
  const bubbleMessage({
    super.key,
    required this.messages,
    this.sender,
    this.isMe = false,
  });

  final String? messages;
  final String? sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(sender!),
          Material(
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24))
                : const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                messages!,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
