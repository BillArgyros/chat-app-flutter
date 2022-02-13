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
  bool roomExists = false;
  String chatText = '';
  FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                      if (data.exists) {
                        ChatRoomData chatRoom =
                            ChatRoomData(uid: data['uid'], chat: data['chat']);
                        return getChatBody(
                            screenWidth, screenHeight, chatRoom, time);
                      } else {
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
      double screenHeight, chatRoomData, time) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
        child: SizedBox(
          // width: screenWidth * 0.8,
          //height: screenHeight*0.09,
          child: TextFormField(
            controller: _controller,
            onChanged: (text) => chatText = text,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  clearChatTextWhiteSpace();
                  if (chatText.isNotEmpty) {
                    FocusScope.of(context).requestFocus(FocusNode());
                    chatRoomData.chat.add({
                      "message": chatText,
                      "user": widget.activeUser.uid,
                      "time": time
                    });
                    if (chatRoomData.uid ==
                        widget.activeUser.uid + widget.secondaryUser.uid) {
                      DatabaseService.fromDatabaseServiceChatRooms(
                              uid1: widget.activeUser.uid,
                              uid2: widget.secondaryUser.uid)
                          .updateChatRoomData(chatRoomData.chat);
                    } else {
                      DatabaseService.fromDatabaseServiceChatRooms(
                              uid1: widget.secondaryUser.uid,
                              uid2: widget.activeUser.uid)
                          .updateChatRoomData(chatRoomData.chat);
                    }
                    setState(() {
                      chatText = '';
                      _controller.clear();
                    });
                  }
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
              InkWell(
                onTap: () {
                  chatBubble['isPressed'] = !chatBubble['isPressed'];
                  print(chatBubble['isPressed']);
                },
                child: Container(
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

  Future<void> createChatRoom() async {
    List chat = [];
    await DatabaseService.fromDatabaseServiceChatRooms(
            uid1: widget.activeUser.uid, uid2: widget.secondaryUser.uid)
        .updateChatRoomData(chat);
  }
}
