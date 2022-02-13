import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  _userFromUserCredential(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  Stream<UserModel> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromUserCredential(user!));
  }

  //register with email
  Future registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      //create a new document for the user with the uid
      await DatabaseService(uid: user!.uid)
          .updateUserData(name, email, password);

      return _userFromUserCredential(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sing in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromUserCredential(user);
    } catch (e) {
      print('e.toString()');
      return null;
    }
  }

  //signOut
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }
}
