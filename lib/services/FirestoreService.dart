import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/services/addExpensePageLogic.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGroupDocument(String groupId) async {
    return await _firestore.collection('grupos').doc(groupId).get();
  }

  Future<void> actualizarGasto(String groupId, String id, Gasto updatedExpense) async {
    DocumentReference expenseDocRef = _firestore.collection('expenses').doc(id);
    await expenseDocRef.update({
      'description': updatedExpense.description,
      'amount': updatedExpense.amount,
      'date': updatedExpense.date,
      'paid': updatedExpense.paid,
      'payer': updatedExpense.payer,
      'payerId': updatedExpense.payerId,
      'category': updatedExpense.category,
    });
  }

  Future<void> eliminarGasto(String groupId, String id) {
    DocumentReference expenseDocRef = _firestore.collection('expenses').doc(id);
    return _firestore.collection('grupos').doc(groupId).update({
      'expenses': FieldValue.arrayRemove([expenseDocRef.id])
    }).then((_) {
      return expenseDocRef.delete();
    });
  }

Future<void> removeUserFromGroup(String groupId, String userId) async {
    DocumentReference groupDocRef = _firestore.collection('grupos').doc(groupId);
    
    try {
      DocumentSnapshot groupDoc = await groupDocRef.get();

      if (groupDoc.exists) {
        var groupData = groupDoc.data() as Map<String, dynamic>;
        if (groupData.containsKey('members')) {
          List<String> miembros = List<String>.from(groupData['members']);
          if (miembros.contains(userId)) {
            miembros.remove(userId);
            await groupDocRef.update({'members': miembros});
          }
        } else {
          print('El campo "members" no existe en el documento del grupo.');
        }
      } else {
        print('El documento del grupo no existe.');
      }
    } catch (e) {
      print('Error al actualizar los miembros del grupo: $e');
    }
  }

  Future<void> removeGroupFromUser(String groupId, String userId) async {
    DocumentReference userDocRef = _firestore.collection('users').doc(userId);
    
    try {
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('grupos')) {
          List<String> grupos = List<String>.from(userData['grupos']);
          if (grupos.contains(groupId)) {
            grupos.remove(groupId);
            await userDocRef.update({'grupos': grupos});
          }
        } else {
          print('El campo "grupos" no existe en el documento del usuario.');
        }
      } else {
        print('El documento del usuario no existe.');
      }
    } catch (e) {
      print('Error al actualizar los grupos del usuario: $e');
    }
  }

  Future<void> deleteGroup(String groupId) async {

  DocumentReference groupDocRef = _firestore.collection('grupos').doc(groupId);

  WriteBatch batch = _firestore.batch();

  batch.delete(groupDocRef);

  DocumentSnapshot groupDoc = await groupDocRef.get();

  if (groupDoc.exists) {
    List<dynamic> expensesIds = groupDoc['expenses'];
    for (String expenseId in expensesIds) {
      DocumentReference expenseDocRef = _firestore.collection('expenses').doc(expenseId);
      batch.delete(expenseDocRef);
    }
  }

  await batch.commit();
  }

 
}




Future<String> getUserName(String userId) async {
  final FirestoreService _firestoreService = FirestoreService();
  DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestoreService.getUserDocument(userId);
  if (userDoc.exists) {
    return userDoc.data()!['userName'];
  } else {
    return 'Usuario desconocido';
  }
}
