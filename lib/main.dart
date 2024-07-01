import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/initial_page.dart';
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
  runApp(MyApp());
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
  
  void changeTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }

  void updateHomePage() {
    notifyListeners();
  }
}
