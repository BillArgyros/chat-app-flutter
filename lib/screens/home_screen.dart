import 'package:chat_app/loading.dart';
import 'package:chat_app/screens/chat_room_screen.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/authentication.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthServices _authServices = AuthServices();

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    //retrieve all the registered users.
    final Stream<QuerySnapshot> users =
        FirebaseFirestore.instance.collection('userInfo').snapshots();
    List<UserData> userList = [];
    //retrieve the active user
    final user = Provider.of<UserModel>(context);
    return StreamBuilder(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          return StreamBuilder<QuerySnapshot?>(
              stream: users,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data!;
                  userList = createUserList(data);
                  //find the active within the user list and create a new object with the user information
                  var activeUserIndex =
                      userList.indexWhere((element) => element.uid == user.uid);
                  var activeUser = userList[activeUserIndex];
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      body: SizedBox(
                        height: screenHeight*1,
                        child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 10.0, left: 10),
                                    child: Text(
                                      'Welcome ' + userList[activeUserIndex].name,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  _signOutButton(
                                      context, screenWidth, screenHeight),
                                ],
                              ),
                              Expanded(
                                child: SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 40.0),
                                    child: SizedBox(
                                      //create a list of all the available users except the active user
                                      child: ListView.builder(
                                        itemCount: userList.length,
                                        itemBuilder: (context, index) {
                                          if (userList[index].uid == user.uid) {
                                            return const SizedBox();
                                          } else {
                                            //create a button that represents a chat room for every registered user
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 0.0),
                                              child: Card(
                                                child: TextButton(
                                                  onPressed: () {
                                                    //pass both the active user and the user that the chat room is being shared with
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatRoom(
                                                                activeUser: activeUser,
                                                                secondaryUser:
                                                                    userList[index],
                                                              )),
                                                    );
                                                  },
                                                  child: ListTile(
                                                    leading: const CircleAvatar(
                                                      radius: 25.0,
                                                      backgroundColor: Colors.brown,
                                                    ),
                                                    title: Text(userList[index].name),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                      ),
                    ),
                  );
                } else {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: Scaffold(
                      body: Stack(
                        children: [
                          SizedBox(
                            height: screenHeight * 1,
                            child: Align(
                              alignment: Alignment.center,
                              child: Loading(),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: _signOutButton(
                                context, screenWidth, screenHeight),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              });
        });
  }

  Widget _signOutButton(context, screenWidth, screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextButton.icon(
        onPressed: () {
          _authServices.signOut();
        },
        label: const Text(''),
        icon: const Icon(
          Icons.logout_outlined,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }

  List<UserData> createUserList(data) {
    List<UserData> userList = [];

    for (var element in data.docs) {
      UserData userData = UserData(
          email: element['email'],
          password: element['password'],
          name: element['name'],
          uid: element['uid']);
      userList.add(userData);
    }

    return userList;
  }
}
