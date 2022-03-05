import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/chat_room_screen.dart';

chatList(
    screenWidth, screenHeight, UserData activeUser, List<UserData> userList) {
  //reverses the list of the users chat rooms in order to have the last active
  //chat room shown on top
  List chatRooms = activeUser.chatRooms.reversed.toList();
  return ListView.builder(
    itemCount: chatRooms.length,
    itemBuilder: (context, index) {
      // find the user that shares the chat room with the current active user
      var userIndex = userList.indexWhere(
          (element) => element.uid == chatRooms[index]['secondaryUser']);
      return chatRooms[index]['lastMessage'].isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Card(
                child: TextButton(
                  onPressed: () {
                    //pass both the active user and the user that the chat room is
                    // being shared with
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatRoom(
                          activeUser: activeUser,
                          secondaryUser: userList[userIndex],
                          chatRoomId: chatRooms[index]['id'],
                        ),
                      ),
                    );
                  },
                  //create a tile that represents a chat room,each chat room
                  //holds the name of the associated user and the last message
                  //that has been sent in each room, the message is properly
                  //formatted to fit the length of the tile and is being styled
                  //according to the state of the message (whether it has been
                  //read or not by the active user)
                  child: ListTile(
                    leading: const CircleAvatar(
                      radius: 25.0,
                      backgroundColor: Color.fromARGB(253, 170, 5, 19),
                    ),
                    title: Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: userList[userIndex].name.length > 10
                          ? Text(
                              userList[userIndex].name.substring(0, 10) + '...',
                              style: chatRooms[index]['lastMessageStatus'] &&
                                      chatRooms[index]['lastSender'] !=
                                          activeUser.uid
                                  ? const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)
                                  : const TextStyle())
                          : Text(userList[userIndex].name,
                              style: chatRooms[index]['lastMessageStatus'] &&
                                      chatRooms[index]['lastSender'] !=
                                          activeUser.uid
                                  ? const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)
                                  : const TextStyle()),
                    ),
                    subtitle: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              chatRooms[index]['lastSender'] == activeUser.uid
                                  ? SizedBox(
                                      width: screenWidth * 0.4,
                                      child:
                                          chatRooms[index]['lastMessage'].length >
                                                  18
                                              ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: SizedBox(
                                                  child: FittedBox(
                                                    child: Text(
                                                      'You: ' +
                                                          chatRooms[index]
                                                                  ['lastMessage']
                                                              .substring(0, 18) +
                                                          '...',
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : Align(
                                            alignment: Alignment.centerLeft,
                                                child: SizedBox(
                                            height: screenHeight*0.02,
                                                  child: FittedBox(
                                                    child: Text('You: ' +
                                                        chatRooms[index]
                                                            ['lastMessage']),
                                                  ),
                                                ),
                                              ),
                                    )
                                  : SizedBox(
                                      width: screenWidth * 0.4,
                                      child: chatRooms[index]['lastMessage']
                                                  .length >
                                              22
                                          ? Align(
                                        alignment: Alignment.centerLeft,
                                        child: SizedBox(
                                          child: FittedBox(
                                                child: Text(
                                                  chatRooms[index]['lastMessage']
                                                          .substring(0, 22) +
                                                      '...',
                                                  style: chatRooms[index]
                                                          ['lastMessageStatus']
                                                      ? const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)
                                                      : const TextStyle(),
                                                ),
                                              ),
                                            ),
                                          )
                                          : Align(
                                        alignment: Alignment.centerLeft,
                                        child: SizedBox(
                                          child: FittedBox(
                                                child: Text(
                                                  chatRooms[index]['lastMessage'],
                                                  style: chatRooms[index]
                                                          ['lastMessageStatus']
                                                      ? const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)
                                                      : const TextStyle(),
                                                ),
                                              ),
                                            ),
                                          )),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  child: FittedBox(
                                    child: Text(chatRooms[index]['lastMessageTime'],
                                        style: chatRooms[index]
                                                    ['lastMessageStatus'] &&
                                                chatRooms[index]['lastSender'] !=
                                                    activeUser.uid
                                            ? const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,fontSize: 8)
                                            : const TextStyle(fontSize: 8)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            )
          : const SizedBox();
    },
  );
}
