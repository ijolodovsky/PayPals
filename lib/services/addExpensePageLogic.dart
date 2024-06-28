import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/services/FirestoreService.dart';
import 'package:flutter_app_gastos/user_auth/firebase_user_authentication/fire_auth_services.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

    DocumentReference nuevaExpenseRef = await _firestore.collection('expenses').add({
      'description': description,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'payer': userName,
      'paid': false,
      'payerId': userId,
      'category': category,
    });

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
  DocumentSnapshot grupoDoc = await _firestore.collection('grupos').doc(groupId).get();
  List<String> miembros = List<String>.from(grupoDoc['members']);

  List<Future<void>> notificaciones = [];
  for (String miembroId in miembros) {
    notificaciones.add(FirebaseFirestore.instance.collection('users').doc(miembroId).get().then((userDoc) {
      String? fcmToken = userDoc['fcmToken'];
      if (fcmToken != null) {
        return _sendPushNotification(fcmToken, description, amount);
      }
      return Future.value();
    }));
  }
  await Future.wait(notificaciones);
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
    DocumentSnapshot grupoDoc = await _firestore.collection('grupos').doc(groupId).get();
    if (grupoDoc.exists) {
      List<String> expensesIds = List<String>.from(grupoDoc['expenses']);
      List<Future<DocumentSnapshot>> expenseDocsFutures = expensesIds.map((id) => _firestore.collection('expenses').doc(id).get()).toList();

      List<DocumentSnapshot> expenseDocs = await Future.wait(expenseDocsFutures);
      List<Gasto> expenses = expenseDocs.where((doc) => doc.exists).map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Gasto(
          id: doc.id,
          description: data['description'],
          amount: data['amount'],
          date: data['date'],
          payer: data['payer'],
          paid: data['paid'],
          payerId: data['payerId'],
          category: data['category'],
        );
      }).toList();

      return expenses;
    }

    return [];
  } catch (error) {
    print('Error al obtener los gastos del grupo: $error');
    rethrow;
  }
}