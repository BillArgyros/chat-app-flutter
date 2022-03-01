import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/chat_room_model.dart';
import 'chat_bubble_manager.dart';

fetchChatData(BuildContext context, double screenWidth, double screenHeight,
    ChatRoomData chatRoom,activeUser) {
  return chatRoom.chat
      .map<Widget>((chatBubble) =>
      getChatBubbles(chatBubble, screenWidth, screenHeight, context,activeUser))
      .toList();
}

