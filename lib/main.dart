import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/launch_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'firebase_options.dart';
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp();
//   print('Handling a background message ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
    //   options: FirebaseOptions(
    //       apiKey: configurations.apiKey,
    //       appId: configurations.appId,
    //       messagingSenderId: configurations.messagingSenderId,
    //       projectId: configurations.projectId));

  );
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // testData();

    return MaterialApp(
      title: 'Monster Project Team',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(
            primary: Colors.grey[900],
              secondary: Colors.lightGreenAccent[700]),
          appBarTheme: AppBarTheme(
            foregroundColor: Colors.redAccent[400],
          )
          // textTheme: const TextTheme(
          //     headline6: TextStyle(color: Colors.white)
          // ).apply(displayColor: Colors.redAccent[400])
      ),
      home: LaunchScreen(),
    );
  }

  Future testData() async {
    await Firebase.initializeApp();
    FirebaseFirestore db = FirebaseFirestore.instance;
    var data = await db.collection('event_details').get();
    var details = data.docs.toList();

    for (var d in details) {
      print(d.id);
    }
  }
}