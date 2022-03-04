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

  //this focus node is responsible for closing the keyboard and un-focusing
  // from the text field
  late String chatRoomId;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  var index = -1;
  bool roomExists = false;
  UserData activeUser =
      UserData(email: '', uid: '', password: '', name: '', chatRooms: []);
  UserData secondaryUser =
      UserData(email: '', uid: '', password: '', name: '', chatRooms: []);

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    String time = DateFormat.Hm().format(now);
    //find the correct collection document for the specific chat room
    var room = getChatRoomCollection();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: room,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            ChatRoomData chatRoom =
                ChatRoomData(uid: data['uid'], chat: data['chat']);
            var index = widget.activeUser.chatRooms
                .indexWhere((element) => element['id'] == chatRoom.uid);
            if (index > -1) {
              widget.activeUser.chatRooms[index]['lastMessageStatus'] = false;
              DatabaseService(uid: widget.activeUser.uid).updateUserData(
                  widget.activeUser.name,
                  widget.activeUser.email,
                  widget.activeUser.password,
                  widget.activeUser.chatRooms);
            }
            return getChatBody(screenWidth, screenHeight, chatRoom, time);
          } else {
            return Loading();
          }
        });
  }

  getAppBar() {
    return AppBar(
      title: widget.secondaryUser.name.length > 10
          ? Text(
              widget.secondaryUser.name.substring(0, 10) + '...',
              style: const TextStyle(color: Colors.black),
            )
          : Text(
              widget.secondaryUser.name,
              style: const TextStyle(color: Colors.black),
            ),
      elevation: 10,
      backgroundColor: const Color.fromARGB(253, 170, 5, 19),
      bottom: PreferredSize(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(width: 1, color: Colors.black)),
            ),
          ),
          preferredSize: const Size.fromHeight(0.0)),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
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
                //when the icon is pressed sent the data to the database
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
            // when pressing any part of the screen the focus is being
            // unfocused from the text field
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
                    //create a scroll view that is responsible for rendering
                    // the messages between the users
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

  getChatRoomCollection() {
    //if the ChatRoomScreen is being called by the HomeScreen, the constructor
    // will definitely contain a valid chatRoomId since the room already exists
    if (widget.chatRoomId.isNotEmpty) {
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(widget.chatRoomId)
          .snapshots();
      //if the active user has a chat room that is being shared with the other
      // user, the chat room definitely exists
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
      //if roomExists is true, it means that during this session the chat room
      // has been created
    } else if (roomExists) {
      return FirebaseFirestore.instance
          .collection('chatRoom')
          .doc(chatRoomId)
          .snapshots();
      //if the roomExists is false, the chat room does not exist yet and
      // createChatRoom is being called
    } else {
      createChatRoom();
    }
  }

  Future<void> createChatRoom() async {
    List chat = [];
    List chatRooms = [];
    // we create the chat room between the 2 users, the id for the document is
    // the combination of the id of the 2 users
    await DatabaseService.fromDatabaseServiceChatRooms(
            chatId: widget.activeUser.uid + widget.secondaryUser.uid)
        .updateChatRoomData(chat)
        .then((value) => setState(() {
              //after the creation of the room we set the variables to their
              // appropriate values
              roomExists = true;
              //chatRoomId = widget.chatRoomId;
              chatRoomId = widget.activeUser.uid + widget.secondaryUser.uid;
            }));
    //update both users providing them with the chat room information
    chatRooms.addAll(widget.activeUser.chatRooms);
    chatRooms.add({
      'id': widget.activeUser.uid + widget.secondaryUser.uid,
      'secondaryUser': widget.secondaryUser.uid,
      'lastMessage': '',
      'lastSender': '',
      'lastMessageTime': '',
      'lastMessageStatus': false
    });
    activeUser.chatRooms = chatRooms;
    await DatabaseService(uid: widget.activeUser.uid)
        .updateUserData(widget.activeUser.name, widget.activeUser.email,
            widget.activeUser.password, chatRooms)
        .then((value) => widget.activeUser.chatRooms = chatRooms);
    chatRooms = [];
    chatRooms.addAll(widget.secondaryUser.chatRooms);
    chatRooms.add({
      'id': widget.activeUser.uid + widget.secondaryUser.uid,
      'secondaryUser': widget.activeUser.uid,
      'lastMessage': '',
      'lastSender': '',
      'lastMessageTime': '',
      'lastMessageStatus': false
    });
    secondaryUser.chatRooms = chatRooms;
    await DatabaseService(uid: widget.secondaryUser.uid)
        .updateUserData(widget.secondaryUser.name, widget.secondaryUser.email,
            widget.secondaryUser.password, chatRooms)
        .then((value) => widget.secondaryUser.chatRooms = chatRooms);
  }

  Future<void> manageMessageData(chatRoom, time) async {
    var index = -1;
    setState(() {
      //format the text
      chatText = clearChatTextWhiteSpace(chatText);
    });
    if (chatText.isNotEmpty) {
      List chatRooms = [];
      FocusScope.of(context).requestFocus(FocusNode());
      chatRoom.chat.add(
          {"message": chatText, "user": widget.activeUser.uid, "time": time});
      //update the chat room with the proper id
      if (widget.chatRoomId.isNotEmpty) {
        DatabaseService.fromDatabaseServiceChatRooms(chatId: widget.chatRoomId)
            .updateChatRoomData(chatRoom.chat);
        chatRooms = widget.activeUser.chatRooms;
        index = chatRooms
            .indexWhere((element) => element['id'] == widget.chatRoomId);
        chatRooms[index]['lastMessage'] = chatText;
        chatRooms[index]['lastSender'] = widget.activeUser.uid;
        chatRooms[index]['lastMessageTime'] = time;
        chatRooms[index]['lastMessageStatus'] = false;
        chatRooms.add(chatRooms[index]);
        chatRooms.removeAt(index);
        DatabaseService(uid: widget.activeUser.uid).updateUserData(
            widget.activeUser.name,
            widget.activeUser.email,
            widget.activeUser.password,
            chatRooms);
        chatRooms = [];
        chatRooms = widget.secondaryUser.chatRooms;
        index = chatRooms
            .indexWhere((element) => element['id'] == widget.chatRoomId);
        chatRooms[index]['lastMessage'] = chatText;
        chatRooms[index]['lastSender'] = widget.activeUser.uid;
        chatRooms[index]['lastMessageTime'] = time;
        chatRooms[index]['lastMessageStatus'] = true;
        chatRooms.add(chatRooms[index]);
        chatRooms.removeAt(index);
        await DatabaseService(uid: widget.secondaryUser.uid).updateUserData(
            widget.secondaryUser.name,
            widget.secondaryUser.email,
            widget.secondaryUser.password,
            chatRooms);
      } else {
        await DatabaseService.fromDatabaseServiceChatRooms(chatId: chatRoomId)
            .updateChatRoomData(chatRoom.chat);
        chatRooms = widget.activeUser.chatRooms;
        index = chatRooms.indexWhere((element) => element['id'] == chatRoomId);
        chatRooms[index]['lastMessage'] = chatText;
        chatRooms[index]['lastSender'] = widget.activeUser.uid;
        chatRooms[index]['lastMessageTime'] = time;
        chatRooms[index]['lastMessageStatus'] = false;
        chatRooms.add(chatRooms[index]);
        chatRooms.removeAt(index);
        await DatabaseService(uid: widget.activeUser.uid).updateUserData(
            widget.activeUser.name,
            widget.activeUser.email,
            widget.activeUser.password,
            chatRooms);
        chatRooms = [];
        chatRooms = widget.secondaryUser.chatRooms;
        index = chatRooms.indexWhere((element) => element['id'] == chatRoomId);
        chatRooms[index]['lastMessage'] = chatText;
        chatRooms[index]['lastSender'] = widget.activeUser.uid;
        chatRooms[index]['lastMessageTime'] = time;
        chatRooms[index]['lastMessageStatus'] = true;
        chatRooms.add(chatRooms[index]);
        chatRooms.removeAt(index);
        await DatabaseService(uid: widget.secondaryUser.uid).updateUserData(
            widget.secondaryUser.name,
            widget.secondaryUser.email,
            widget.secondaryUser.password,
            chatRooms);
      }
      //clear the text field information once the message is sent
      setState(() {
        chatText = '';
        _controller.clear();
      });
    }
  }
}
