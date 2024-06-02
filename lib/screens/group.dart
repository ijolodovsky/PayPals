import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/screens/add_expense.dart'; // Importa la pantalla de añadir gasto

class GroupScreen extends StatelessWidget {
  final String groupName; // Nombre del grupo (debes proporcionarlo)

  GroupScreen({required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Esto llevará al usuario de vuelta a la página anterior (la pantalla de inicio)
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.blue, // Color del grupo
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.group, // Cambia el icono según tus preferencias
                    size: 40,
                    color: Colors.white, // Cambia el color según tus preferencias
                  ),
                  SizedBox(width: 10),
                  Text(
                    groupName,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 10),
                  DebtTile(
                    debtor: 'Micaela',
                    amount: 699.32,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Acción al presionar el botón de liquidar deudas
                    },
                    child: Text('Liquidar Deudas'),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Listado de gastos:',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ExpenseTile(
                          month: 'Feb.',
                          day: '18',
                          title: 'Uber',
                          payer: 'Pagaste',
                          amount: 7000.0,
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón de añadir gasto
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen()), // Navegar a la pantalla de añadir gasto
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DebtTile extends StatelessWidget {
  final String debtor;
  final double amount;

  DebtTile({
    required this.debtor,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '$debtor te debe \$${amount.toStringAsFixed(2)}',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final String month;
  final String day;
  final String title;
  final String payer;
  final double amount;

  ExpenseTile({
    required this.month,
    required this.day,
    required this.title,
    required this.payer,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 10), // Margen inferior para evitar el desbordamiento
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1),
            Text(
              day,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '$payer \$${amount.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}
