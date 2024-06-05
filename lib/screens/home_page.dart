import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'add_group.dart';
import 'group.dart';
import 'initial_page.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  HomeScreen({required this.userName});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<DocumentSnapshot<Map<String, dynamic>>>> _groupDocuments;

  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() {
    setState(() {
      _groupDocuments = _firestoreService.getUserDocument(FirebaseAuth.instance.currentUser!.uid)
          .then((userDoc) {
        final List<String> groupIds = List<String>.from(userDoc['grupos']);
        return Future.wait(groupIds.map((groupId) => _firestoreService.getGroupDocument(groupId)));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payPals'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.menu),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: Text("Cerrar Sesión"),
                  value: "logout",
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
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final groupDocs = snapshot.data!;
                return ListView.builder(
                  itemCount: groupDocs.length,
                  itemBuilder: (context, index) {
                    final groupName = groupDocs[index]['groupName'];
                    final amount = 150.0;
                    final isDebt = true;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: GroupButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GroupScreen(groupName: groupName)),
                          );
                        },
                        groupName: groupName,
                        amount: amount,
                        isDebt: isDebt,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _reloadData();
            },
            backgroundColor: Theme.of(context).colorScheme.background,
            tooltip: 'Actualizar grupos',
            child: Icon(Icons.refresh),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddGroupPage()),
              );
              _reloadData();
            },
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.background,
            tooltip: 'Agregar nuevo grupo de Pals',
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              _reloadData();
            },
            child: Icon(Icons.person_add),
            backgroundColor: Theme.of(context).colorScheme.background,
            tooltip: 'Unirse a un grupo de Pals',
          ),
        ],
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
            Icons.circle, // Change icon based on preference
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
