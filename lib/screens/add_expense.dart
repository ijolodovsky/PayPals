import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;

  AddExpenseScreen({required this.groupId});

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

  void _addExpense() async {
    final description = _descriptionController.text;
    final amount = double.parse(_amountController.text);

    if (_validateAmount(_amountController.text)) {
      try {
        await cargarGastoEnGrupo(widget.groupId, description, amount);
        Navigator.pop(context);
      } catch (error) {
        print('Error al agregar el gasto: $error');
      }
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
