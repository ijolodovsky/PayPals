import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool _validateAmount(String value) {
    if (value.isEmpty) {
      return false;
    }
    final amount = double.tryParse(value);
    return amount != null && amount > 0;
  }

  void _addExpense() {
    final description = _descriptionController.text; // Obtener la descripción del gasto
    final amount = double.parse(_amountController.text); // Obtener el monto del gasto
    
    // Aquí puedes implementar la lógica para añadir el gasto
    if (_validateAmount(_amountController.text)) {
      // Ejemplo de implementación: mostrar un diálogo de confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmar'),
            content: Text('¿Deseas agregar el gasto "$description" por \$${amount.toStringAsFixed(2)}?'),
            actions: [
              TextButton(
                onPressed: () {
                  // Agregar el gasto aquí
                  Navigator.pop(context); // Cerrar el diálogo
                  // Puedes ejecutar la lógica para agregar el gasto a tu base de datos o donde sea necesario
                },
                child: Text('Aceptar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el diálogo
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Gasto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descripción:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Descripción del gasto',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Monto:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Monto',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              child: Text('Añadir Gasto'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
