import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/text_trimmer.dart';
import 'package:flutter/material.dart';

import 'chat_room_screen.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen.SearchScreen({Key? key}) : super(key: key);

  List<UserData> userList = [];
  late UserData activeUser;

  SearchScreen({Key? key, required this.userList, required this.activeUser})
      : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchUser = '';
  bool searching = false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    getBackArrow(context),
                    searchBar(screenWidth, screenHeight),
                  ],
                ),
                // if the user starts searching for other users the showMatchingUsers is being called
                searching
                    ? showMatchingUsers()
                    : const SizedBox(),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget searchBar(double screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10),
      child: SizedBox(
        width: screenWidth * 0.7,
        child: Container(
          padding: const EdgeInsets.only(left: 20),
          child: TextField(
            autofocus: true,
            style: const TextStyle(
              fontSize: 17,
            ),
            onChanged: (text) {
              setState(() {
                searchUser = text;
                //if the searchUser string is empty stop searching for users

                if (searchUser == '') {
                  searching = false;
                } else {
                  //trim the whitespace before and after the text
                  searchUser=clearChatTextWhiteSpace(searchUser);
                  //after trimming the text if the text is not empty look for users
                  if (searchUser!='') {
                    searching = true;
                  }
                }
              });
            },
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(
              hintText: 'Search user...',
              hintStyle: TextStyle(fontSize: 15, color: Colors.black),
              focusColor: Colors.transparent,
              fillColor: Colors.transparent,
              hoverColor: Colors.transparent,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget getBackArrow(context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back,
      ),
    );
  }


  //look for any user that contains the string that is being typed by the user
 Widget showMatchingUsers() {
    return Expanded(
      child: SizedBox(
        child: ListView.builder(
          itemCount: widget.userList.length,
          itemBuilder: (context, index) {
            if (widget.userList[index].name
                .toLowerCase()
                .contains(searchUser.toLowerCase())) {
              if (widget.userList[index].uid !=
                  widget.activeUser.uid) {
                return userInfo(index);
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }

  Widget userInfo(index) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: Card(
        child: TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            //pass both the active user and the user that the chat room is
            // being shared with
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatRoom(
                    activeUser:
                    widget.activeUser,
                    secondaryUser: widget
                        .userList[index], chatRoomId: '',
                  )),
            );
          },
          child: ListTile(
            leading: const CircleAvatar(
              radius: 25.0,
              backgroundColor: Color.fromARGB(253, 170, 5, 19),
            ),
            title:
            Text(widget.userList[index].name),
          ),
        ),
      ),
    );
  }
}
