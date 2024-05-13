import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    // Implementar el diseño de la pantalla de login
    // contiene un formulario con los campos de correo y contraseña
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
              TextField(
                decoration: InputDecoration(
                  hintText: 'Correo',
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Ingresar'),
                onPressed: () {
                  // Implementar la lógica de inicio de sesión con Firebase
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Olvidé mi contraseña'),
                onPressed: () {
                  // Implementar la lógica de inicio de sesión con Firebase
                },
              ),
            ],
          ),
        ),
      ),
    );
    
  }
}