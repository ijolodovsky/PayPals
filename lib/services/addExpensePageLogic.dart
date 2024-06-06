import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/user_auth/firebase_user_authentication/fire_auth_services.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;



class Gasto {
  final String description;
  final double amount;
  final Timestamp date;
  final String payer;

  Gasto({
    required this.description,
    required this.amount,
    required this.date,
    required this.payer,
  });

}

Future<String> cargarGastoEnGrupo(String groupId, String description, double amount) async {
  try {
    DocumentReference grupoDocRef = FirebaseFirestore.instance.collection('grupos').doc(groupId);

    Gasto nuevoGasto = Gasto(
      description: description,
      amount: amount,
      date: Timestamp.now(),
      payer: obtenerIdUsuarioActual(),
    );

    // Actualizar el campo 'expenses' del documento con el nuevo gasto
    await grupoDocRef.update({
      'expenses': FieldValue.arrayUnion([nuevoGasto]),
    });

    return 'Gasto agregado correctamente';
  } catch (error) {
    print('Error al cargar el gasto en el grupo: $error');
    rethrow;
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
        )).toList();
        return expenses;
      }
    }

    return [];
  } catch (error) {
    print('Error al obtener los gastos del grupo: $error');
    throw error;
  }
}


