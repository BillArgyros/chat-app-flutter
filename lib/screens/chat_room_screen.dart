import 'package:chat_app/loading.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  var activeUser;
  var secondaryUser;

  ChatRoom({Key? key, required this.activeUser, required this.secondaryUser})
      : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  //contains the text that is being typed
  String chatText = '';
  //this focus node is responsible for closing the keyboard and un-focusing from the text field
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    // room1 and room2 are responsible for fetching the chat room that is connected between users
    // a chat room is create with an id that is the combination of the id the 2 users have, so it can either be user1.id+user2.id or user2.id+user1.id
    // that means we need to check the chatRoom collection for 2 ids each time in order to check whether the chat room pre exists and snatch the data
    var room1 = FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(widget.activeUser.uid + widget.secondaryUser.uid)
        .snapshots();
    var room2 = FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(widget.secondaryUser.uid + widget.activeUser.uid)
        .snapshots();
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    String time = DateFormat.Hm().format(now);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: room1,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            //if the first reference contains data it means we can create the object with the appropriate data
            if (data.exists) {
              ChatRoomData chatRoom =
                  ChatRoomData(uid: data['uid'], chat: data['chat']);
              return getChatBody(screenWidth, screenHeight, chatRoom, time);
            } else {
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: room2,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;
                      //if the first reference does not contain any data we check the second reference
                      if (data.exists) {
                        //if the second reference contains data it means we can create the object with the appropriate data
                        ChatRoomData chatRoom =
                            ChatRoomData(uid: data['uid'], chat: data['chat']);
                        return getChatBody(
                            screenWidth, screenHeight, chatRoom, time);
                      } else {
                        //if neither of the references contain data it means the chat room between the 2 users has not been created yet
                        createChatRoom();
                        ChatRoomData chatRoom = ChatRoomData(uid: '', chat: []);
                        return getChatBody(
                            screenWidth, screenHeight, chatRoom, time);
                      }
                    } else {
                      return Loading();
                    }
                  });
            }
          } else {
            return Loading();
          }
        });
  }

  getAppBar() {
    return AppBar(
      title: Text(
        widget.secondaryUser.name,
        style: const TextStyle(color: Colors.black),
      ),
      elevation: 10,
      backgroundColor: Colors.deepOrange,
      bottom: PreferredSize(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.black)),
            ),
          ),
          preferredSize: const Size.fromHeight(0.0)),
      leading: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
    );
  }

  _textFieldFormat(BuildContext context, double screenWidth,
      double screenHeight, chatRoom, time) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: SizedBox(
          child: TextFormField(
            controller: _controller,
            onChanged: (text) => chatText = text,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  manageMessageData(chatRoom,time);
                },
                icon: const Icon(Icons.send),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              labelText: 'Chat',
            ),
            textInputAction: TextInputAction.newline,
            focusNode: _focusNode,
          ),
        ),
      ),
    );
  }

  fetchChatData(BuildContext context, double screenWidth, double screenHeight,
      ChatRoomData chatRoom) {
    return chatRoom.chat
        .map<Widget>((chatBubble) =>
            getChatBubbles(chatBubble, screenWidth, screenHeight, context))
        .toList();
  }


  getChatBubbles(chatBubble, double screenWidth, double screenHeight,
      BuildContext context) {
    if (chatBubble['user'] == widget.activeUser.uid) {
      return Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                constraints:
                    BoxConstraints(minWidth: 0, maxWidth: screenWidth * 0.6),
                decoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    chatBubble['message'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10.0),
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        chatBubble['time'],
                        style: const TextStyle(fontSize: 8),
                      ))),
            ],
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                constraints:
                    BoxConstraints(minWidth: 0, maxWidth: screenWidth * 0.6),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    chatBubble['message'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 2, left: 10.0),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        chatBubble['time'],
                        style: const TextStyle(fontSize: 8),
                      ))),
            ],
          ),
        ),
      );
    }
  }

  //this method is responsible for clearing any with space before and after the beginning of the message
  void clearChatTextWhiteSpace() {
    setState(() {
      chatText = chatText.trimLeft();
      chatText = chatText.trimRight();
    });
  }

  getChatBody(
      double screenWidth, double screenHeight, ChatRoomData chatRoom, time) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: getAppBar(),
        body: InkWell(
          splashColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SizedBox(
            width: screenWidth * 1,
            height: screenHeight * 1,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: screenWidth * 1,
                    child: SingleChildScrollView(
                      reverse: true,
                      child: chatRoom.chat.isNotEmpty
                          ? Column(
                              children: fetchChatData(
                                  context, screenWidth, screenHeight, chatRoom),
                            )
                          : SizedBox(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: _textFieldFormat(context, screenWidth,
                                screenHeight, chatRoom, time),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //we create the chat room between the 2 users, the id for the document is the combination of the if of the 2 users
  Future<void> createChatRoom() async {
    List chat = [];
    await DatabaseService.fromDatabaseServiceChatRooms(
            uid1: widget.activeUser.uid, uid2: widget.secondaryUser.uid)
        .updateChatRoomData(chat);
  }


  void manageMessageData(chatRoom,time) {
    clearChatTextWhiteSpace();
    if (chatText.isNotEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());
      chatRoom.chat.add({
        "message": chatText,
        "user": widget.activeUser.uid,
        "time": time
      });
      //update the chat room with the proper id
      if (chatRoom.uid ==
          widget.activeUser.uid + widget.secondaryUser.uid) {
        DatabaseService.fromDatabaseServiceChatRooms(
            uid1: widget.activeUser.uid,
            uid2: widget.secondaryUser.uid)
            .updateChatRoomData(chatRoom.chat);
      } else {
        DatabaseService.fromDatabaseServiceChatRooms(
            uid1: widget.secondaryUser.uid,
            uid2: widget.activeUser.uid)
            .updateChatRoomData(chatRoom.chat);
      }
      //clear the text field information once the message is sent
      setState(() {
        chatText = '';
        _controller.clear();
      });
    }
  }
}
