import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

class ExpensesChartScreen extends StatefulWidget {
  final String groupId;

  ExpensesChartScreen({required this.groupId});

  @override
  _ExpensesChartScreenState createState() => _ExpensesChartScreenState();
}

class _ExpensesChartScreenState extends State<ExpensesChartScreen> {
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  Future<Map<String, double>> _fetchExpensesByCategory() async {
    List<Gasto> expenses = await obtenerGastosDeGrupo(widget.groupId);
    Map<String, double> expensesByCategory = {};
    expenses.forEach((expense) {
      if (expensesByCategory.containsKey(expense.category)) {
        expensesByCategory[expense.category] = expensesByCategory[expense.category]! + expense.amount;
      } else {
        expensesByCategory[expense.category] = expense.amount;
      }
    });
    return expensesByCategory;
  }

  Future<Map<String, double>> _fetchExpensesByPerson() async {
    List<Gasto> expenses = await obtenerGastosDeGrupo(widget.groupId);
    Map<String, double> expensesByPerson = {};
    expenses.forEach((expense) {
      if (expensesByPerson.containsKey(expense.payerId)) {
        expensesByPerson[expense.payer] = expensesByPerson[expense.payer]! + expense.amount;
      } else {
        expensesByPerson[expense.payer] = expense.amount;
      }
    });
    return expensesByPerson;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráficos'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Gastos por categoría',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder<Map<String, double>>(
              future: _fetchExpensesByCategory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
                } else {
                  Map<String, double> expensesByCategory = snapshot.data ?? {};
                  return Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 0,
                            centerSpaceRadius: 50,
                            sections: expensesByCategory.entries.map((entry) {
                              final color = getColorForCategory(entry.key);
                              return PieChartSectionData(
                                color: color,
                                value: entry.value,
                                radius: 80,
                                title: '',
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: expensesByCategory.entries.map((entry) {
                          final color = getColorForCategory(entry.key);
                          return ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            title: Text(entry.key),
                            trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Gastos por persona',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Ajuste en el margen
              child: FutureBuilder<Map<String, double>>(
                future: _fetchExpensesByPerson(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error al cargar los datos: ${snapshot.error}'));
                  } else {
                    Map<String, double> expensesByPerson = snapshot.data ?? {};
                    return Column(
                      children: expensesByPerson.entries.map((entry) {
                        final color = getColorForPerson(entry.key);
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              SizedBox(width: 8),
                              Text(entry.key),
                              SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: entry.value / expensesByPerson.values.reduce((a, b) => a + b),
                                  color: color,
                                  backgroundColor: color.withOpacity(0.2),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('\$${entry.value.toStringAsFixed(2)}'),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getColorForCategory(String categoryName) {
    final int colorIndex = categoryName.hashCode % colors.length;
    return colors[colorIndex];
  }

  Color getColorForPerson(String personId) {
    final int colorIndex = personId.hashCode % colors.length;
    return colors[colorIndex];
  }
}