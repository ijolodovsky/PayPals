import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../user_auth/firebase_user_authentication/fire_auth_services.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _invalidEmail = false;
  bool _invalidPassword = false;

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
                width: 200,
                height: 200,
                padding: EdgeInsets.all(30),
                child: Image.asset('assets/images/logo1.png'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Correo',
                  hintStyle: TextStyle(color: Colors.black54),
                  errorText: _invalidEmail ? 'Correo electrónico inválido' : null,
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colors.black54),
                  errorText: _invalidPassword ? 'Contraseña inválida' : null,
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Ingresar'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showPasswordResetDialog,
                child: Text('Olvidé mi contraseña'),
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

    setState(() {
      _invalidEmail = false;
      _invalidPassword = false;
    });

    try {
      User? user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        String? userName = await _authService.getUserName(user.uid);
        if (userName != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: userName)),
          );
        } else {
          throw Exception('Nombre de usuario no encontrado');
        }
      } else {
        // Usuario no encontrado o contraseña incorrecta
        setState(() {
          _invalidEmail = true;
          _invalidPassword = true;
        });
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

  void _showPasswordResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController resetEmailController = TextEditingController();

        return AlertDialog(
          title: Text('Restablecer contraseña'),
          content: TextField(
            controller: resetEmailController,
            decoration: InputDecoration(
              hintText: 'Ingrese su correo electrónico',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enviar'),
              onPressed: () async {
                String resetEmail = resetEmailController.text;

                try {
                  await _authService.sendPasswordResetEmail(resetEmail);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Correo de restablecimiento enviado')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al enviar el correo de restablecimiento: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
