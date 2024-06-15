import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_gastos/screens/add_expense.dart';
import 'package:flutter_app_gastos/screens/ajuste_cuentas.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/firestoreService.dart';
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

  Future<List<String>> _fetchParticipants() async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc = await FirestoreService().getGroupDocument(widget.groupId);
    if (groupDoc.exists && groupDoc.data()!.containsKey('members')) {
      return List<String>.from(groupDoc.data()!['members']);
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _fetchParticipantsDetails() async {
    List<String> participantIds = await _fetchParticipants();
    List<Map<String, dynamic>> participantsDetails = [];
    for (String userId in participantIds) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirestoreService().getUserDocument(userId);
      if (userDoc.exists) {
        participantsDetails.add(userDoc.data()!);
      }
    }
    return participantsDetails;
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
        actions: [
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  height: 400,
                  child: Column(
                    children: [
                      Expanded(
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _fetchParticipantsDetails(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error al cargar los participantes: ${snapshot.error}'));
                            } else {
                              List<Map<String, dynamic>> participants = snapshot.data ?? [];
                              return ListView.builder(
                                itemCount: participants.length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> participant = participants[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      child: Text(
                                        participant['userName']
                                            .toString()
                                            .substring(0, 1)
                                            .toUpperCase(),
                                      ),
                                    ),
                                    title: Text(participant['userName']),
                                    subtitle: Text(participant['email']),
                                  );
                                },
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          // Lógica para abandonar el grupo
                          // Por ejemplo, podrías llamar a un método que maneje esto
                          // _leaveGroup();
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          padding: MaterialStateProperty.all(EdgeInsets.all(16)),
                        ),
                        child: Text('Abandonar Grupo', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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
                  if (_totalUnpaidExpenses > 0)
                    DebtTile(
                      totalUnpaid: _totalUnpaidExpenses,
                    ),
                  if (_totalUnpaidExpenses == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Todos los gastos fueron saldados', style: TextStyle(fontSize: 18)),
                        ],
                      ),
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
                        _reloadData();
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
                              if (expenses.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No hay gastos en el grupo',
                                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                                  ),
                                );
                              }
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Total de gastos sin ajustar:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            '\$$totalUnpaid',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
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
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: paid ? Colors.grey.shade200 : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: <Widget>[
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 12,
                    color: paid ? Colors.grey[600] : Colors.blue,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: paid ? Colors.grey[600] : Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: paid ? Colors.grey[600] : Colors.black,
                  ),
                ),
                Text(
                  'Pagado por: $payer',
                  style: TextStyle(
                    fontSize: 16,
                    color: paid ? Colors.grey[600] : Colors.black,),
                ),
              ],
            ),
          ),
          if (!paid)
                IconButton(
                  icon: Icon(Icons.edit),
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                    iconColor: MaterialStateProperty.all(Colors.grey[600]),    
                    iconSize: MaterialStateProperty.all(14),     
                  ),
                  onPressed: () {
                    // fncionalidad de edición
                  },
              ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '\$$amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: paid ? Colors.grey[600] : Colors.red,
                ),
              ),
              if (!paid)
                Text(
                  'Sin saldar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}