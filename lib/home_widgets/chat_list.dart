import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/chat_room_screen.dart';

chatList(
    screenWidth, screenHeight, UserData activeUser, List<UserData> userList) {
  List chatRooms = activeUser.chatRooms.reversed.toList();
  return ListView.builder(
    reverse: false,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            chatRooms[index]['lastSender'] == activeUser.uid
                                ? SizedBox(
                                    height: screenHeight * 0.025,
                                    width: screenWidth * 0.5,
                                    child: chatRooms[index]['lastMessage']
                                                .length >
                                            18
                                        ? Text(
                                            'You: ' +
                                                chatRooms[index]['lastMessage']
                                                    .substring(0, 18) +
                                                '...',
                                          )
                                        : Text('You: ' +
                                            chatRooms[index]['lastMessage']),
                                  )
                                : SizedBox(
                                    child: chatRooms[index]['lastMessage']
                                                .length >
                                            22
                                        ? Text(
                                            chatRooms[index]['lastMessage']
                                                    .substring(0, 22) +
                                                '...',
                                            style: chatRooms[index]
                                                    ['lastMessageStatus']
                                                ? const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)
                                                : const TextStyle(),
                                          )
                                        : Text(
                                            chatRooms[index]['lastMessage'],
                                            style: chatRooms[index]
                                                    ['lastMessageStatus']
                                                ? const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold)
                                                : const TextStyle(),
                                          )),
                            Text(chatRooms[index]['lastMessageTime'],
                                style: chatRooms[index]['lastMessageStatus'] &&
                                        chatRooms[index]
                                                ['lastSender'] !=
                                            activeUser.uid
                                    ? const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)
                                    : const TextStyle())
                          ],
                        )),
                  ),
                ),
              ),
            )
          : const SizedBox();
    },
  );
}
