import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app_gastos/generals.dart';
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

  int _selectedIndex = 0; // 0: Gastos por categoría, 1: Gastos por persona

  Future<List<PieChartSectionData>> _fetchExpensesByCategoryData() async {
    List<Gasto> expenses = await obtenerGastosDeGrupo(widget.groupId);
    Map<String, double> expensesByCategory = {};
    double totalAmount = 0;

    expenses.forEach((expense) {
      totalAmount += expense.amount;
      if (expensesByCategory.containsKey(expense.category)) {
        expensesByCategory[expense.category] =
            expensesByCategory[expense.category]! + expense.amount;
      } else {
        expensesByCategory[expense.category] = expense.amount;
      }
    });

    List<PieChartSectionData> sections = [];

    expensesByCategory.entries.forEach((entry) {
      final color = getColorForCategory(entry.key);
      final IconData icon = getIconForCategory(entry.key);
      final double percentage = entry.value / totalAmount * 100;

      sections.add(PieChartSectionData(
        color: color,
        value: entry.value,
        radius: 120,
        title: '',
        badgeWidget: percentage > 5 // Mostrar ícono solo si la porción es mayor al 5%
            ? Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                ),
              )
            : null,
      ));
    });

    return sections;
  }

  Future<Map<String, double>> _fetchExpensesByCategory() async {
    List<Gasto> expenses = await obtenerGastosDeGrupo(widget.groupId);
    Map<String, double> expensesByCategory = {};
    expenses.forEach((expense) {
      if (expensesByCategory.containsKey(expense.category)) {
        expensesByCategory[expense.category] =
            expensesByCategory[expense.category]! + expense.amount;
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
        expensesByPerson[expense.payer] =
            expensesByPerson[expense.payer]! + expense.amount;
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16), // Reducción del padding horizontal
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: ToggleButtons(
                  isSelected: [_selectedIndex == 0, _selectedIndex == 1],
                  onPressed: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Gastos por categoría'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Gastos por persona'),
                    ),
                  ],
                ),
              ),
              if (_selectedIndex == 0) ...[
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 24),
                  child: Text(
                    'Gastos por categoría',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<PieChartSectionData>>(
                  future: _fetchExpensesByCategoryData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Error al cargar los datos: ${snapshot.error}'));
                    } else {
                      List<PieChartSectionData> sections = snapshot.data ?? [];
                      return Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 1.8,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 20,
                                sections: sections,
                              ),
                            ),
                          ),
                          SizedBox(height: 10), // Reducción del espacio vertical
                          FutureBuilder<Map<String, double>>(
                            future: _fetchExpensesByCategory(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState
                                  .waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Error al cargar los datos: ${snapshot.error}'));
                              } else {
                                Map<String, double> expensesByCategory =
                                    snapshot.data ?? {};
                                return Column(
                                  children:
                                      expensesByCategory.entries.map((entry) {
                                    final color =
                                        getColorForCategory(entry.key);
                                    final icon = getIconForCategory(entry.key);
                                    return ListTile(
                                      leading: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            icon,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(entry.key),
                                      trailing: Text(
                                          '\$${entry.value.toStringAsFixed(2)}'),
                                    );
                                  }).toList(),
                                );
                              }
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ] else if (_selectedIndex == 1) ...[
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Gastos por persona',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0), // Ajuste en el margen
                  child: FutureBuilder<Map<String, double>>(
                    future: _fetchExpensesByPerson(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                'Error al cargar los datos: ${snapshot.error}'));
                      } else {
                        Map<String, double> expensesByPerson =
                            snapshot.data ?? {};
                        return Column(
                          children:
                              expensesByPerson.entries.map((entry) {
                            final color = getColorForCategory(entry.key);
                            return Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 4.0), // Reducción del padding vertical
                              child: Row(
                                children: [
                                  SizedBox(width: 8),
                                  Text(entry.key),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: entry.value /
                                          expensesByPerson.values
                                              .reduce((a, b) => a + b),
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
            ],
          ),
        ),
      ),
    );
  }

  Color getColorForCategory(String categoryName) {
    final int colorIndex = categoryName.hashCode % colors.length;
    return colors[colorIndex];
  }


}