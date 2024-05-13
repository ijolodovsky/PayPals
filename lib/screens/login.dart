import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/home_page.dart';

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
              Container(
                width: 200, // Ancho deseado
                height: 200, // Alto deseado
                padding: EdgeInsets.all(30),
                child: Image.asset('assets/images/image.png'),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Correo',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colors.black54)
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Ingresar'),
                onPressed: () {
                  // Implementar la lógica de inicio de sesión con Firebase

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
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