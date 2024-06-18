import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/initial_page.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBliv3875udBp2EARP3CTs0iR2t4eIZSU8",
      authDomain: "flutter-app-gastos.firebaseapp.com",
      projectId: "flutter-app-gastos",
      storageBucket: "flutter-app-gastos.appspot.com",
      messagingSenderId: "991144222743",
      appId: "1:991144222743:web:42594cfc7086965f6b3c52",
      measurementId: "G-7DBWEPP817"
    ),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'PayPals',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFF28d6f9)),
          buttonTheme: ButtonThemeData(
            buttonColor: const Color.fromARGB(255, 39, 125, 129),
            textTheme: ButtonTextTheme.primary,
          ),
          fontFamily: GoogleFonts.montserrat().fontFamily,
          scaffoldBackgroundColor: const Color(0xFFfdfdfd),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String _title = 'PayPals';
  String get title => _title;

  MyAppState() {
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    
    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // Get the token each time the application loads
      String? token = await messaging.getToken();
      print("FCM Token: $token");
      // Here, save the token to your database
      await saveTokenToDatabase(token!);
      // Configure the foreground message handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Got a message whilst in the foreground!");
        print("Message data: ${message.data}");
        if (message.notification != null) {
          print("Message also contained a notification: ${message.notification}");
          // Show a dialog or notification in the app
        }
      });

      // Configure the background message handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Message clicked!");
        // Handle notification click action
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void changeTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  void updateHomePage() {
    notifyListeners();
  }
}
