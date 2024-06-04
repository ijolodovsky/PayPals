import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(String email, String password, String userName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // Crear un documento en Firestore para el usuario recién registrado
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'userName': userName,
          'groups': <String>[],
        });
      }
      return user;
    } catch (e) {
      print('Error al registrarse: $e');
      throw e; // Propagar el error para que se maneje en el código de la aplicación
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
    }
    return null;
  }

  Future<String?> getUserName(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc['userName'];
    } catch (e) {
      print('Error al obtener el nombre de usuario: $e');
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar el correo de restablecimiento: $e');
    }
  }
}

String obtenerIdUsuarioActual() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid;
  } else {
    throw Exception('Usuario no autenticado');
  }
}
