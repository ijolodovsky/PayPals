import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/add_group.dart';
import 'package:flutter_app_gastos/screens/group.dart';
import 'package:flutter_app_gastos/screens/initial_page.dart'; // Importa el archivo donde se encuentra MyHomePage

class HomeScreen extends StatelessWidget {
  final String userName; // Nombre del usuario (debes proporcionarlo)

  HomeScreen({required this.userName});

  // Método para mostrar el diálogo de unirse a un grupo de Pals
  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresa el código del grupo:'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Código'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Acción al presionar el botón de aceptar
                // Aquí puedes implementar la lógica para unirse al grupo
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payPals'),
        automaticallyImplyLeading: false, // Elimina la flecha hacia atrás
        actions: [
          // Agrega un IconButton para mostrar el menú desplegable
          PopupMenuButton(
            icon: Icon(Icons.menu), // Agrega un icono al botón del menú
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: "logout",
                  child: Text("Cerrar Sesión"),
                ),
              ];
            },
            onSelected: (value) {
              if (value == "logout") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()), // Reemplaza la pantalla actual por MyHomePage
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Círculo con la inicial del nombre del usuario
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue, // Puedes cambiar el color
              child: Text(
                userName.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            // Nombre del usuario
            Text(
              '¡Bienvenido, $userName!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            // Listado de grupos de gastos
            Text(
              'Tus Grupos de Gastos:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Lista de grupos de gastos (puedes usar ListView.builder)
            GroupButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupScreen(groupName: 'Grupo amor',)),
                );
              },
              groupName: 'Grupo 1',
              amount: 150.0, 
              isDebt: true, 
            ),
            SizedBox(height: 10),
            GroupButton(
              onPressed: () {
                // Acción al presionar el botón del grupo de gastos
              },
              groupName: 'Grupo 2',
              amount: 80.0, 
              isDebt: false, 
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Acción al presionar el botón de agregar nuevo grupo de Pals
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddGroupPage()),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.background,
            tooltip: 'Agregar nuevo grupo de Pals',
            child: Icon(Icons.add),
          ),
          SizedBox(width: 10), // Separación entre los botones
          FloatingActionButton(
            onPressed: () {
              // Acción al presionar el botón de unirse a un grupo de Pals
              _showJoinGroupDialog(context);
            },
            backgroundColor: Theme.of(context).colorScheme.background,
            tooltip: 'Unirse a un grupo de Pals',
            child: Icon(Icons.person_add),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
class GroupButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String groupName;
  final double amount;
  final bool isDebt;

  GroupButton({
    required this.onPressed,
    required this.groupName,
    required this.amount,
    required this.isDebt,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle, // Cambia el icono según tus preferencias
            color: isDebt ? Colors.red : Colors.green,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(groupName),
              Text(
                isDebt ? 'Debes \$${amount.toStringAsFixed(2)}' : 'Te deben \$${amount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
