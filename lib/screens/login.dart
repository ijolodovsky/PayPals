import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_auth/firebase_user_authentication/fire_auth_services.dart';

class LoginPage extends StatefulWidget {
 @override
 _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 200, // Ancho deseado
                height: 200, // Alto deseado
                padding: EdgeInsets.all(30),
                child: Image.asset('assets/images/image.png'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Correo',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Ingresar'),
                onPressed: _login,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Olvidé mi contraseña'),
                onPressed: () {
                  // Implementar la lógica para recuperar la contraseña
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        print('Inicio de sesión exitoso: ${user.uid}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(userName: user.email ?? 'Usuario')),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Error al iniciar sesión: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.message}')),
      );
    } catch (e) {
      print('Error inesperado: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error inesperado: $e')),
      );
    }
  }
}
