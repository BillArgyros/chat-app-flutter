import '../models/user_model.dart';

List<UserData> createUserList(data) {
  List<UserData> userList = [];
  for (var element in data.docs) {
    UserData userData = UserData(
        email: element['email'],
        password: element['password'],
        name: element['name'],
        uid: element['uid'],
        chatRooms: element['chatRooms']);
    userList.add(userData);
  }
  return userList;
}