import 'package:flutter/material.dart';

class AddGroupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Grupo de Gastos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: 'Nombre del Grupo',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Descripción del Grupo',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              SizedBox(height: 20),
              Text("con vos y:"),
              TextField(
                decoration: InputDecoration(
                  hintText: 'mails de tus amigos separados por comas',
                  hintStyle: TextStyle(color: Colors.black54),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Crear Grupo'),
                onPressed: () {
                  // Implementar la lógica para crear un nuevo grupo de gastos
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}