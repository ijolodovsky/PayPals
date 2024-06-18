import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_gastos/user_auth/firebase_user_authentication/fire_auth_services.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getGroupDocument(String groupId) async {
    return await _firestore.collection('grupos').doc(groupId).get();
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

Future<void> saveTokenToDatabase(String token) async {
  final FirestoreService _firestoreService = FirestoreService();
  String userId = obtenerIdUsuarioActual();
  DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestoreService.getUserDocument(userId);
  if (userDoc.exists) {
    await userDoc.reference.update({'fcmToken': token});
  }
}