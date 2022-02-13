
import 'package:chat_app/models/chat_room_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
   String uid='';
   String uid1='';
   String uid2='';

  DatabaseService({ required this.uid});
  DatabaseService.fromDatabaseServiceChatRooms({required this.uid1,required this.uid2});

  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection('userInfo');
  final CollectionReference chatRoomInfo =
      FirebaseFirestore.instance.collection('chatRoom');

  Future updateUserData(String name, String email, String password) async {
    return await userInfo.doc(uid).set({
      'name': name,
      'email': email,
      'password': password,
      'uid': uid,
    });
  }

  Future updateChatRoomData(chat) async {
    return await chatRoomInfo.doc(uid1 + uid2).set({
      'uid': uid1 + uid2,
      'chat': chat,
    });
  }

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        email: snapshot.get('email'),
        password: snapshot.get('password'),
        name: snapshot.get('name'),
        uid: snapshot.get('uid'));
  }

  Stream<UserData> get userData {
    return userInfo.doc(uid).snapshots().map(_userDataFromSnapshot);
  }



}
