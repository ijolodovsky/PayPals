import 'package:flutter/material.dart';



class RegistroPage extends StatefulWidget {
  @override
  _RegistroPageState createState() => _RegistroPageState();


}

class _RegistroPageState extends State<RegistroPage> {
  @override
  Widget build(BuildContext context) {
    // Implementar el diseño de la pantalla de registro
    // contiene un formulario con los campos de nombre, correo, contraseña y botón de registro
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
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
                  hintText: 'Nombre Completo',
                  hintStyle: TextStyle(color: Colors.black54)
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Correo',
                  hintStyle: TextStyle(color: Colors.black54)
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(color: Colors.black54)
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Repetir Contraseña',
                  hintStyle: TextStyle(color: Colors.black54)
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Registrar'),
                onPressed: () {
                  // Implementar la lógica de registro con Firebase
                  
                },
              ),
            ],
          ),
        ),
      ),
    );
    
  }
}