import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../screens/chat_room_screen.dart';

chatList(UserData activeUser, List<UserData> userList) {
  return ListView.builder(
    itemCount: activeUser.chatRooms.length,
    itemBuilder: (context, index) {
      // find the user that shares the chat room with the current active user
      var userIndex = userList.indexWhere(
              (element) =>
          element.uid ==
              activeUser.chatRooms[index]
              ['secondaryUser']);
      return activeUser.chatRooms[index]['lastMessage'].isNotEmpty? Padding(
        padding:
        const EdgeInsets.only(top: 0.0),
        child: Card(
          child: TextButton(
            onPressed: () {
              //pass both the active user and the user that the chat room is
              // being shared with
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatRoom(
                        activeUser:
                        activeUser,
                        secondaryUser:
                        userList[
                        userIndex], chatRoomId: activeUser.chatRooms[index]['id'],),
                ),
              );
            },
            child: ListTile(
              leading: const CircleAvatar(
                radius: 25.0,
                backgroundColor: Color.fromARGB(253, 170, 5, 19),
              ),
              title: Padding(
                padding:
                const EdgeInsets.only(
                    bottom: 10.0),
                child: Text(
                    userList[userIndex].name),
              ),
              subtitle:  Padding(
                padding: const EdgeInsets.only(
                    bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    activeUser.chatRooms[index]['lastSender']==activeUser.uid? Text(
                        'You: ' + activeUser.chatRooms[index]['lastMessage']):
                    Text(activeUser.chatRooms[index]['lastMessage']),
                    Text(activeUser.chatRooms[index]['lastMessageTime'])
                  ],
                )
              ),
            ),
          ),
        ),
      ):const SizedBox();
    },
  );
}