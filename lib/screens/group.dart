import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_gastos/screens/add_expense.dart';
import 'package:flutter_app_gastos/screens/ajuste_cuentas.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class GroupScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  GroupScreen({required this.groupId, required this.groupName});

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  late Future<List<Gasto>> _expensesFuture;
  double _totalUnpaidExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    setState(() {
      _expensesFuture = obtenerGastosDeGrupo(widget.groupId);
      _calculateTotalUnpaidExpenses();
    });
  }

  Future<void> _calculateTotalUnpaidExpenses() async {
    List<Gasto> expenses = await obtenerGastosDeGrupo(widget.groupId);
    double total = expenses.where((gasto) => !gasto.paid).fold(0.0, (sum, gasto) => sum + gasto.amount);
    setState(() {
      _totalUnpaidExpenses = total;
    });
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.groupId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Código copiado al portapapeles')),
    );
  }

  void _shareGroupCode() {
    Share.share('Únete a nuestro grupo usando el código: ${widget.groupId}');
  }

  String obtenerNombreMesAbreviado(DateTime fecha) {
    final locale = Intl.getCurrentLocale();
    final formatter = DateFormat('MMM', locale);
    return formatter.format(fecha).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Grupo"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.group,
                    size: 40,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.groupName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                    totalUnpaid: _totalUnpaidExpenses,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AjustarCuentas(groupId: widget.groupId),
                        ),
                      );
                      if (result == true) {
                        _reloadData();  // Recargar datos si se saldaron las deudas
                      }
                    },
                    child: Text('Ajustar cuentas'),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<List<Gasto>>(
                          future: _expensesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Text('Error al obtener los gastos del grupo: ${snapshot.error}');
                            } else {
                              List<Gasto> expenses = snapshot.data ?? [];
                              expenses.sort((a, b) => b.date.compareTo(a.date));
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Gastos:',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: expenses.map((expense) {
                                      DateTime date = expense.date.toDate();
                                      return ExpenseTile(
                                        month: obtenerNombreMesAbreviado(date),
                                        day: date.day.toString(),
                                        title: expense.description,
                                        payer: expense.payer,
                                        amount: expense.amount,
                                        paid: expense.paid,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExpenseScreen(groupId: widget.groupId),
                  ),
                ).then((_) {
                  _reloadData();
                });
              },
              child: Icon(Icons.add),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 80),
            child: Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButton(
                onPressed: copyToClipboard,
                child: Icon(Icons.copy),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class DebtTile extends StatelessWidget {
  final double totalUnpaid;

  DebtTile({required this.totalUnpaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: totalUnpaid > 0 ? Colors.orange[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            totalUnpaid > 0 ? Icons.warning : Icons.check_circle,
            color: totalUnpaid > 0 ? Colors.orange : Colors.green,
          ),
          SizedBox(width: 10),
          Text(
            totalUnpaid > 0
                ? 'Total de gastos no pagados: \$${totalUnpaid.toStringAsFixed(2)}'
                : 'No hay gastos pendientes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: totalUnpaid > 0 ? Colors.orange[800] : Colors.green[800],
            ),
          ),
        ],
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
  final bool paid;

  ExpenseTile({
    required this.month,
    required this.day,
    required this.title,
    required this.payer,
    required this.amount,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {
    final amountFormatted = NumberFormat('#,##0.00', 'es_ES').format(amount);

    return Container(
      decoration: BoxDecoration(
        color: paid ? Colors.grey[200] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              month,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
          payer,
          style: TextStyle(fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!paid)
              IconButton(
                icon: Icon(Icons.edit),
                iconSize: 20,
                color: Colors.grey[400],
                padding: EdgeInsets.zero,
                onPressed: () {
                  // Lógica para editar el gasto
                },
              ),
            Text(
              '\$$amountFormatted',
              style: TextStyle(
                fontSize: 16,
                color: paid ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
