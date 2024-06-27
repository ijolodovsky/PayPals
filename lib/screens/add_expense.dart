import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';
import 'package:intl/intl.dart'; // Asegúrate de agregar esta dependencia en tu pubspec.yaml

class AddExpenseScreen extends StatefulWidget {
  final String groupId;

  AddExpenseScreen({required this.groupId});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedCategory;

  final List<String> _categories = [
    'Comida',
    'Transporte',
    'Alojamiento',
    'Entretenimiento',
    'Salud',
    'Hogar',
    'SUBE',
    'Compras',
    'Educación',
    'Ropa',
    'Otros',
  ];

  bool _validateAmount(String value) {
    if (value.isEmpty) {
      return false;
    }
    final amount = double.tryParse(value);
    return amount != null && amount > 0;
  }

  bool _validateDescription(String value) {
    return value.isNotEmpty;
  }

  void _addExpense() async {
    final description = _descriptionController.text;
    final amountText = _amountController.text;

    if (_validateDescription(description) &&
        _validateAmount(amountText) &&
        _selectedDate != null &&
        _selectedCategory != null) {
      final amount = double.parse(amountText);
      try {
        String result = await cargarGastoEnGrupo(widget.groupId, description, amount, _selectedDate!, _selectedCategory!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
        Navigator.pop(context);
      } catch (error) {
        print('Error al agregar el gasto: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al agregar el gasto')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor complete todos los campos correctamente')));
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Establece la fecha actual como la última fecha seleccionable
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  IconData getIconForCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'comida':
        return Icons.fastfood;
      case 'transporte':
        return Icons.directions_car;
      case 'entretenimiento':
        return Icons.local_movies;
      case 'salud':
        return Icons.favorite;
      case 'alojamiento':
        return Icons.hotel;
      default:
        return Icons.category;
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Fecha:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'Seleccione una fecha'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Seleccionar Fecha'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Categoría:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    hint: Text('Seleccione una categoría'),
                    items: _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCategory = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                if (_selectedCategory != null)
                  Icon(
                    getIconForCategory(_selectedCategory!),
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Añadir Gasto'),
              ),
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
