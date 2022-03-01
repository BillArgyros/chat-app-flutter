import 'package:chat_app/loading.dart';
import 'package:chat_app/models/chat_room_model.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/text_trimmer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../chat_room_manager/chat_data.dart';

class ChatRoom extends StatefulWidget {
  UserData activeUser;
  UserData secondaryUser;
  String chatRoomId = '';

  ChatRoom(
      {Key? key,
      required this.activeUser,
      required this.secondaryUser,
      required this.chatRoomId})
      : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  //contains the text that is being typed
  String chatText = '';

  //this focus node is responsible for closing the keyboard and un-focusing from the text field
  late String chatRoomId;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  var index = -1;
  bool roomExists = false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    String time = DateFormat.Hm().format(now);
    var room = getChatRoomCollection();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: room,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            ChatRoomData chatRoom =
                ChatRoomData(uid: data['uid'], chat: data['chat']);
            return getChatBody(screenWidth, screenHeight, chatRoom, time);
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
      backgroundColor: Color.fromARGB(253, 170, 5, 19),
      bottom: PreferredSize(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.black)),
            ),
          ),
          preferredSize: const Size.fromHeight(0.0)),
      leading: IconButton(
        onPressed: () {
          //Navigator.popUntil(context, ModalRoute.withName ('/'));
          Navigator.pop(context);
          //Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
    );
  }

  _textFieldFormat(BuildContext context, double screenWidth,
      double screenHeight, chatRoom, time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: SizedBox(
        child: TextFormField(
          textCapitalization: TextCapitalization.sentences,
          controller: _controller,
          onChanged: (text) => chatText = text,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 5,
          decoration: InputDecoration(
            suffixIcon: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                manageMessageData(chatRoom, time);
              },
              child: const Icon(Icons.send),
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
    );
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
                  child: SizedBox(
                    width: screenWidth * 1,
                    child: SingleChildScrollView(
                      reverse: true,
                      child: chatRoom.chat.isNotEmpty
                          ? Column(
                              children: fetchChatData(context, screenWidth,
                                  screenHeight, chatRoom, widget.activeUser),
                            )
                          : const SizedBox(),
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

  //we create the chat room between the 2 users, the id for the document is the combination of the id of the 2 users
  Future<void> createChatRoom() async {
    List chat = [];
    List chatRooms = [];
    await DatabaseService.fromDatabaseServiceChatRooms(
            chatId: widget.activeUser.uid + widget.secondaryUser.uid)
        .updateChatRoomData(chat)
        .then((value) => setState(() {
              roomExists = true;
              chatRoomId = widget.chatRoomId;
              chatRoomId = widget.activeUser.uid + widget.secondaryUser.uid;
            }));
    chatRooms.addAll(widget.activeUser.chatRooms);
    chatRooms.add({
      'id': widget.activeUser.uid + widget.secondaryUser.uid,
      'secondaryUser': widget.secondaryUser.uid
    });
    await DatabaseService(uid: widget.activeUser.uid).updateUserData(
        widget.activeUser.name,
        widget.activeUser.email,
        widget.activeUser.password,
        chatRooms);
    chatRooms = [];
    chatRooms.addAll(widget.secondaryUser.chatRooms);
    chatRooms.add({
      'id': widget.activeUser.uid + widget.secondaryUser.uid,
      'secondaryUser': widget.activeUser.uid
    });

    await DatabaseService(uid: widget.secondaryUser.uid).updateUserData(
        widget.secondaryUser.name,
        widget.secondaryUser.email,
        widget.secondaryUser.password,
        chatRooms);
  }

  void manageMessageData(chatRoom, time) {
    setState(() {
      chatText = clearChatTextWhiteSpace(chatText);
    });
    if (chatText.isNotEmpty) {
      FocusScope.of(context).requestFocus(FocusNode());
      chatRoom.chat.add(
          {"message": chatText, "user": widget.activeUser.uid, "time": time});
      //update the chat room with the proper id
      if (widget.chatRoomId.isNotEmpty) {
        DatabaseService.fromDatabaseServiceChatRooms(chatId: widget.chatRoomId)
            .updateChatRoomData(chatRoom.chat);
      } else {
        DatabaseService.fromDatabaseServiceChatRooms(chatId: chatRoomId)
            .updateChatRoomData(chatRoom.chat);
      }
      //clear the text field information once the message is sent
      setState(() {
        chatText = '';
        _controller.clear();
      });
    }
  }

  getChatRoomCollection() {
    if (widget.chatRoomId.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.chatRoomId)
          .snapshots();
    } else if (widget.activeUser.chatRooms.indexWhere((element) =>
            element['secondaryUser'] == widget.secondaryUser.uid) !=
        -1) {
      index = widget.activeUser.chatRooms.indexWhere(
          (element) => element['secondaryUser'] == widget.secondaryUser.uid);
      chatRoomId = widget.activeUser.chatRooms[index]['id'];
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.activeUser.chatRooms[index]['id'])
          .snapshots();
    } else if (roomExists) {
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(chatRoomId)
          .snapshots();
    } else {
      createChatRoom();
    }
  }
}
