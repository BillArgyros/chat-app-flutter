import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  String uid = '';
  String chatId='';

  DatabaseService({required this.uid});

  DatabaseService.fromDatabaseServiceChatRooms(
      {required this.chatId});

  //reference the collection in firebase

  final CollectionReference userInfo =
      FirebaseFirestore.instance.collection('userInfo');
  final CollectionReference chatRoomInfo =
      FirebaseFirestore.instance.collection('chatRoom');

  //create a user in the UserInfo collection when a new user registers
  Future updateUserData(
      String name, String email, String password, chatRooms) async {
    return await userInfo.doc(uid).set({
      'name': name,
      'email': email,
      'password': password,
      'uid': uid,
      'chatRooms': chatRooms
    });
  }

  //create/update a new chat room,when a room is created it gets an id that consists of the active user id + the user id that the active user is sharing a chat room with
  //the chat property is a list of maps that holds information about every message being sent (sender id, message,time message was sent)
  Future updateChatRoomData(chat) async {
    return await chatRoomInfo.doc(chatId).set({
      'uid': chatId,
      'chat': chat,
    });
  }

  //create a user object from the snapshot that is being returned from the firebase

  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
        email: snapshot.get('email'),
        password: snapshot.get('password'),
        name: snapshot.get('name'),
        uid: snapshot.get('uid'),
        chatRooms: snapshot.get('chatRooms'));
  }

  Stream<UserData> get userData {
    return userInfo.doc(uid).snapshots().map(_userDataFromSnapshot);
  }
}
