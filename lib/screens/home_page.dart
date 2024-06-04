import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'add_group.dart';
import 'group.dart';
import 'initial_page.dart'; // Importa el archivo donde se encuentra MyHomePage

class HomeScreen extends StatelessWidget {
  final String userName;
  final FirestoreService _firestoreService = FirestoreService();

  HomeScreen({required this.userName});

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
          // Logo y Bienvenida
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Text(
              userName.substring(0, 1).toUpperCase(),
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '¡Bienvenido, $userName!',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 30),
          // Lista de grupos de gastos
          Text(
            'Tus Grupos de Gastos:',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Expanded(
            child: FutureBuilder(
              future: _firestoreService.getUserDocument(FirebaseAuth.instance.currentUser!.uid),
              builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final userDoc = snapshot.data!;
                final List<String> groupIds = List<String>.from(userDoc['groups']);
                return ListView.builder(
                  itemCount: groupIds.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder(
                      future: _firestoreService.getGroupDocument(groupIds[index]),
                      builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> groupSnapshot) {
                        if (groupSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (groupSnapshot.hasError) {
                          return Text('Error: ${groupSnapshot.error}');
                        }
                        final groupName = groupSnapshot.data!['groupName'];
                        final amount = 150.0; // Monto hardcodeado por ahora
                        final isDebt = true; // Valor hardcodeado por ahora
                        return GroupButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GroupScreen(groupName: groupName)),
                            );
                          },
                          groupName: groupName,
                          amount: amount,
                          isDebt: isDebt,
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
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddGroupPage()),
              );
            },
            child: Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.background,
            tooltip: 'Agregar nuevo grupo de Pals',
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              // Acción al presionar el botón de unirse a un grupo de Pals
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
            Icons.circle, // Cambia el icono según tus preferencias
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
