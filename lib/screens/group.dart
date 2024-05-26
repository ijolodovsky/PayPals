import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/add_expense.dart';

class GroupScreen extends StatelessWidget {
  final String groupName; // Nombre del grupo de gastos

  GroupScreen({required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payPals'),
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
                groupName.substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            // Nombre del usuario
            Text(
              groupName,
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 30),
            // Listado de grupos de gastos
            Text(
              'Lista de Gastos:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            // Lista de grupos de gastos (puedes usar ListView.builder)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón de agregar nuevo grupo de gastos
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpense()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.background,
        tooltip: 'Agregar nuevo grupo de Pals',
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
