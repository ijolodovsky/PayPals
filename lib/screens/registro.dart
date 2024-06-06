import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../user_auth/firebase_user_authentication/fire_auth_services.dart';
import 'home_page.dart';

class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 200,
                    height: 200,
                    padding: EdgeInsets.all(30),
                    child: Image.asset('assets/images/logo1.png'),
                  ),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Nombre Completo',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su nombre completo';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Correo',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo';
                      } else if (!value.contains('@') || !value.contains('.')) {
                        return 'Por favor ingrese un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su contraseña';
                      } else if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Repetir Contraseña',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor repita su contraseña';
                      } else if (value != _passwordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signup,
                    child: Text('Registrar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        User? user = await _authService.signUpWithEmailAndPassword(email, password, username);
        if (user != null) {
          print('Usuario registrado con éxito: ${user.uid}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen(userName: username)),
          );
        }
      } on FirebaseAuthException catch (e) {
        print('Error al registrar el usuario: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el usuario: ${e.message}')),
        );
      } catch (e) {
        print('Error inesperado: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    }
  }
}
