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
                      //find the active within the user list and create a new
                      // object with the user information
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
                                    child: activeUser.name.length > 10
                                        ? Text(
                                            'Welcome ' +
                                                activeUser.name
                                                    .substring(0, 9) +
                                                '...',
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : Text(
                                            'Welcome ' + activeUser.name,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )),
                                signOutButton(context, screenWidth,
                                    screenHeight, _authServices),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: searchButton(context, screenWidth,
                                  screenHeight, userList, activeUser),
                            ),
                            SizedBox(
                              height: screenHeight * 0.13,
                              child: displayAvailableUsers(userList,activeUser,screenWidth,screenHeight),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  //create a list of all the chat rooms that
                                  // the user is attached to
                                  child: activeUser.chatRooms.isNotEmpty
                                      ? chatList(screenWidth, screenHeight,
                                          activeUser, userList)
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 150.0),
                                          child: Center(
                                              child: Text(
                                            'No Active Chats',
                                            style: TextStyle(
                                                color: Colors.black
                                                    .withOpacity(0.5)),
                                          ))),
                                ),
                              ),
                            ),
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
                            child: signOutButton(context, screenWidth,
                                screenHeight, _authServices),
                          ),
                        ],
                      );
                    }
                  });
            }),
      ),
    );
  }

  displayAvailableUsers(userList,activeUser,screenWidth,screenHeight) {
    //creates a horizontal list of all the available users
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: userList.length,
        itemBuilder: (context, index) {
          List chatRooms = [];
          chatRooms = activeUser.chatRooms;
          //checks if a chatroom tha is being shared by the 2 users exists
          var roomIndex = chatRooms.indexWhere(
                  (element) =>
              element['secondaryUser'] ==
                  userList[index].uid);
          var chatRoomId = '';
          if (roomIndex == -1) {
            chatRoomId = '';
          } else {
            chatRoomId = chatRooms[roomIndex]['id'];
          }
          return activeUser.uid != userList[index].uid
              ? Padding(
            padding: const EdgeInsets.only(
                left: 10.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatRoom(
                            activeUser:
                            activeUser,
                            secondaryUser:
                            userList[index],
                            chatRoomId:
                            chatRoomId),
                  ),
                );
              },
              child: SizedBox(
                child: Column(
                  children: [
                     const Expanded(
                       child: CircleAvatar(
                         radius: 25.0,
                         backgroundColor:
                         Color.fromARGB(
                             253, 170, 5, 19),
                       ),
                     ),
                    //displays the name of the users and adjust its length
                    Center(
                      child: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: userList[index].name.length > 6
                                    ? Text(
                                        userList[index].name.substring(0, 6) +
                                            '...',
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    : Text(userList[index].name,
                                        style: const TextStyle(fontSize: 12))),
                          )
                  ],
                ),
              ),
            ),
          )
              : const SizedBox();
        },
      ),
    );
  }
}
