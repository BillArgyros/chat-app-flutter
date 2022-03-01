import 'package:chat_app/loading.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_widgets/chat_list.dart';
import '../home_widgets/search_button.dart';
import '../home_widgets/sign_out_button.dart';
import '../home_widgets/user_data_manager.dart';
import '../models/user_model.dart';
import '../services/authentication.dart';
import 'package:provider/provider.dart';
import 'chat_room_screen.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StreamBuilder(
            stream: DatabaseService(uid: user.uid).userData,
            builder: (context, snapshot) {
              return StreamBuilder<QuerySnapshot?>(
                  stream: users,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data!;
                      //store all the users
                      userList = createUserList(data);
                      //find the active within the user list and create a new object with the user information
                      var activeUserIndex = userList
                          .indexWhere((element) => element.uid == user.uid);
                      var activeUser = userList[activeUserIndex];
                      return SizedBox(
                        height: screenHeight * 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10.0, left: 30),
                                  child: Text(
                                    'Welcome ' + userList[activeUserIndex].name,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                signOutButton(
                                    context, screenWidth, screenHeight,_authServices),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: searchButton(context, screenWidth,
                                  screenHeight, userList, activeUser),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: activeUser.chatRooms.isNotEmpty? chatList(activeUser,userList):
                                       Padding(
                                       padding: const EdgeInsets.only(bottom: 150.0),

                                       child: Center(child: Text('No Active Chats',style: TextStyle(color: Colors.black.withOpacity(0.5)),))),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    } else {
                      return Stack(
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
                            child: signOutButton(
                                context, screenWidth, screenHeight,_authServices),
                          ),
                        ],
                      );
                    }
                  });
            }),
      ),
    );
  }


}
