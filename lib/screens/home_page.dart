import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/add_group.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payPals: dividí gastos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Aquí se mostrará el nombre del usuario
            Text(
              '¡Bienvenido, [nombre del usuario]!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            // Aquí se mostrará el listado de grupos de gastos
            Text(
              'Tus Grupos de Gastos:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            // Lista de grupos de gastos (botones)
            // Puedes reemplazar esto con un ListView.builder si los grupos provienen de una lista
            ElevatedButton(
              onPressed: () {
                // Acción al presionar el botón del grupo de gastos
              },
              child: Text('Grupo 1'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Acción al presionar el botón del grupo de gastos
              },
              child: Text('Grupo 2'),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Acción al presionar el botón del grupo de gastos
              },
              // texto para unirse a un grupo existente en negrita
              child: Text(
                'Unirse a un grupo existente',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // Agrega más botones según sea necesario para cada grupo de gastos
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón de agregar nuevo grupo de gastos
          Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGroupPage()),
                );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).backgroundColor,
        tooltip: 'Agregar nuevo grupo de Pals',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
