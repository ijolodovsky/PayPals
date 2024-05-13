import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/registro.dart';
import 'package:flutter_app_gastos/screens/login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'payPals',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0x28D6F9)),
          buttonTheme: ButtonThemeData(
            buttonColor: const Color.fromARGB(255, 39, 125, 129),
            textTheme: ButtonTextTheme.primary,
          ),
          fontFamily: GoogleFonts.montserrat().fontFamily,
          scaffoldBackgroundColor: const Color(0xFFFDFD),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  String _title = 'payPals';
  String get title => _title;

  void changeTitle(String newTitle) {
    _title = newTitle;
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payPals'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(30),
              child: Image.asset('assets/images/image.png'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistroPage()),
                );
              },
              child: Text('Registro'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}