import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'package:flutter_app_gastos/screens/add_group.dart';
import 'package:flutter_app_gastos/screens/group.dart';
import 'package:flutter_app_gastos/screens/initial_page.dart';
import 'package:flutter_app_gastos/widgets/joinGroupDialog.dart';
import 'package:flutter_app_gastos/services/addGroupPageLogic.dart';
import 'package:flutter_app_gastos/services/debtsLogic.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<DocumentSnapshot<Map<String, dynamic>>>> _groupDocuments;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    setState(() {
      isLoading = true;
      _groupDocuments = _firestoreService
          .getUserDocument(FirebaseAuth.instance.currentUser!.uid)
          .then((userDoc) {
        final List<String> groupIds = List<String>.from(userDoc['grupos']);
        return Future.wait(
            groupIds.map((groupId) => _firestoreService.getGroupDocument(groupId)));
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      DocumentSnapshot groupDoc =
          await FirebaseFirestore.instance.collection('grupos').doc(groupId).get();

      if (groupDoc.exists) {
        await agregarGrupoAlUsuario(groupId);
        await agregarUsuarioAlGrupo(groupId);
        _reloadData();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('El grupo no existe')));
      }
    } catch (e) {
      print('Error al unirse al grupo: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error al unirse al grupo')));
    }
  }

  Future<Map<String, double>> _getUserBalance(String groupId) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    return obtenerBalanceUsuario(userId, groupId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PayPals'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
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
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Text(
              widget.userName.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '¡Bienvenido, ${widget.userName}!',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 30),
          Text(
            'Tus Grupos de Gastos:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
              future: _groupDocuments,
              builder: (context, AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final groupDocs = snapshot.data!;
                return ListView.builder(
                  itemCount: groupDocs.length,
                  itemBuilder: (context, index) {
                    final groupDoc = groupDocs[index];
                    final groupName = groupDoc['groupName'];
                    final groupId = groupDoc.id;

                    return FutureBuilder<Map<String, double>>(
                      future: _getUserBalance(groupId),
                      builder: (context, balanceSnapshot) {
                        if (balanceSnapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (balanceSnapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Center(
                              child: Text('Error: ${balanceSnapshot.error}'),
                            ),
                          );
                        }
                        final balance = balanceSnapshot.data!;
                        final double userBalance = balance['balance']!;
                        final bool isDebt = userBalance < 0;
                        final bool isEmpty = userBalance == 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: GroupButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GroupScreen(groupId: groupId, groupName: groupName)),
                              );
                              _reloadData();
                            },
                            groupName: groupName,
                            amount: userBalance.abs(),
                            isEmpty: isEmpty,
                            isDebt: isDebt,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0, right: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGroupPage()),
                );
                _reloadData();
              },
              backgroundColor: Theme.of(context).colorScheme.background,
              mini: true,
              tooltip: 'Agregar nuevo grupo de Pals',
              child: Icon(Icons.add),
            ),
            SizedBox(width: 10),
            FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return JoinGroupDialog(
                      onJoin: (groupId) {
                        _joinGroup(groupId);
                      },
                    );
                  },
                );
              },
              backgroundColor: Theme.of(context).colorScheme.background,
              mini: true,
              tooltip: 'Unirse a un grupo de Pals',
              child: Icon(Icons.person_add),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class GroupButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String groupName;
  final double amount;
  final bool isEmpty;
  final bool isDebt;

  GroupButton({
    required this.onPressed,
    required this.groupName,
    required this.amount,
    required this.isEmpty,
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
            Icons.circle,
            color: isDebt ? Colors.red : Colors.green,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(groupName),
              if (isEmpty)
                Text(
                  'No hay gastos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              else
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
