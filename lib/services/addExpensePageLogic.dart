import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_gastos/user_auth/firebase_user_authentication/fire_auth_services.dart';


FirebaseFirestore _firestore = FirebaseFirestore.instance;
FirebaseAuthService _authService = FirebaseAuthService();
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

class Gasto {
  final String description;
  final double amount;
  final Timestamp date;
  final String payer;
  final bool paid;
  final String payerId;

  Gasto({
    required this.description,
    required this.amount,
    required this.date,
    required this.payer,
    required this.paid,
    required this.payerId,
  });

}

Future<String> cargarGastoEnGrupo(String groupId, String description, double amount) async {
  try {
    DocumentReference grupoDocRef = FirebaseFirestore.instance.collection('grupos').doc(groupId);
    String userName = await _authService.getUserName(obtenerIdUsuarioActual()) ?? 'Usuario desconocido';

    Gasto nuevoGasto = Gasto(
      description: description,
      amount: amount,
      date: Timestamp.now(),
      payer: userName,
      paid: false,
      payerId: obtenerIdUsuarioActual(),
    );

    await grupoDocRef.update({
      'expenses': FieldValue.arrayUnion([
        {
          'description': nuevoGasto.description,
          'amount': nuevoGasto.amount,
          'date': nuevoGasto.date,
          'payer': nuevoGasto.payer,
          'paid': nuevoGasto.paid,
          'payerId': nuevoGasto.payerId,
        }
      ]),
    });

    //await notificarNuevoGasto(grupoDocRef.id, nuevoGasto.description, nuevoGasto.amount);
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
    DocumentSnapshot grupoDoc = await FirebaseFirestore.instance.collection('grupos').doc(groupId).get();

    if (grupoDoc.exists) {
      Map<String, dynamic>? grupoData = grupoDoc.data() as Map<String, dynamic>?;

      if (grupoData != null && grupoData.containsKey('expenses')) {
        List<dynamic> expensesData = grupoData['expenses'] ?? [];
        List<Gasto> expenses = expensesData.map((expense) => Gasto(
          description: expense['description'],
          amount: expense['amount'],
          date: expense['date'],
          payer: expense['payer'],
          paid: expense['paid'] ?? false,
          payerId: expense['payerId'],
        )).toList();
        return expenses;
      }
    }

    return [];
  } catch (error) {
    print('Error al obtener los gastos del grupo: $error');
    rethrow;
  }
}