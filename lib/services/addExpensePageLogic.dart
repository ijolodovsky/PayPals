import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'package:flutter_app_gastos/user_auth/firebase_user_authentication/fire_auth_services.dart';


FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuthService _authService = FirebaseAuthService();
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class Gasto {
  final String id;
  final String description;
  final double amount;
  final Timestamp date;
  final String payer;
  final bool paid;
  final String payerId;
  final String category;

  Gasto({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.payer,
    required this.paid,
    required this.payerId,
    required this.category,
  });

}
Future<String> cargarGastoEnGrupo(String groupId, String description, double amount, DateTime date, String category) async {
    try {
      String userId = obtenerIdUsuarioActual();
      String userName = await getUserName(userId);

      CollectionReference expenseCollection = _firestore.collection('expenses');

      Gasto nuevoGasto = Gasto(
        id: '',
        description: description,
        amount: amount,
        date: Timestamp.fromDate(date),
        payer: userName,
        paid: false,
        payerId: userId, // Aquí debes obtener el ID del usuario actual
        category: category,
      );

      DocumentReference nuevaExpenseRef = await expenseCollection.add({
        'description': nuevoGasto.description,
        'amount': nuevoGasto.amount,
        'date': nuevoGasto.date,
        'payer': nuevoGasto.payer,
        'paid': nuevoGasto.paid,
        'payerId': nuevoGasto.payerId,
        'category': nuevoGasto.category,
      });

      // Actualizamos el documento del grupo para agregar el ID del gasto al array 'expenses'
      await _firestore.collection('grupos').doc(groupId).update({
        'expenses': FieldValue.arrayUnion([nuevaExpenseRef.id]),
      });

      return 'Gasto agregado correctamente';
    } catch (error) {
      print('Error al cargar el gasto en el grupo: $error');
      rethrow;
    }
  }

Future<void> notificarNuevoGasto(String groupId, String description, double amount) async {
  DocumentSnapshot grupoDoc = await FirebaseFirestore.instance.collection('grupos').doc(groupId).get();
  List<String> miembros = List<String>.from(grupoDoc['members']);

  for (String miembroId in miembros) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(miembroId).get();
    String? fcmToken = userDoc['fcmToken'];

    if (fcmToken != null) {
      await _sendPushNotification(fcmToken, description, amount);
    }
  }
}

Future<void> _sendPushNotification(String fcmToken, String description, double amount) async {
  try {
    await _firebaseMessaging.sendMessage(
      to: fcmToken,
      data: {
        'title': 'Nuevo gasto',
        'body': 'Se ha agregado un nuevo gasto de $amount€: $description',
      },
    );
    print('Notificación enviada exitosamente');
  } catch (e) {
    print('Error al enviar la notificación: $e');
  }
}


Future<List<Gasto>> obtenerGastosDeGrupo(String groupId) async {
  try {
    print('Obteniendo gastos del grupo $groupId');
    DocumentSnapshot grupoDoc = await FirebaseFirestore.instance.collection('grupos').doc(groupId).get();
    CollectionReference expenseCollection = FirebaseFirestore.instance.collection('expenses');

    if (grupoDoc.exists) {
      Map<String, dynamic>? grupoData = grupoDoc.data() as Map<String, dynamic>?;

      if (grupoData != null && grupoData.containsKey('expenses')) {
        List<dynamic> expensesData = grupoData['expenses'] ?? [];
        //por cada id ir a buscar a la collection expenses la informacion del grupo y añadirlo a la lista de gastos
        List<Gasto> expenses = [];
        for (var expenseId in expensesData) {
          DocumentSnapshot expenseDoc = await expenseCollection.doc(expenseId).get();
          if (expenseDoc.exists) {
            expenses.add(Gasto(
              id: expenseDoc.id,
              description: expenseDoc['description'],
              amount: expenseDoc['amount'],
              date: expenseDoc['date'],
              payer: expenseDoc['payer'],
              paid: expenseDoc['paid'],
              payerId: expenseDoc['payerId'],
              category: expenseDoc['category'],
            ));
          }
        }
        return expenses;
      }
    }

    return [];
  } catch (error) {
    print('Error al obtener los gastos del grupo: $error');
    rethrow;
  }
}