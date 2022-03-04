import 'package:flutter/material.dart';
import '../models/user_model.dart';

getChatBubbles(chatBubble, double screenWidth, double screenHeight,
    BuildContext context,UserData activeUser) {
  if (chatBubble['user'] == activeUser.uid) {
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
                  color: const Color.fromARGB(253, 170, 5, 19),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  )),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  chatBubble['message'],
                  style: const TextStyle(fontSize: 18,color: Color.fromARGB(
                      237, 255, 252, 252)),
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
                  color:  Colors.black12,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.black,
                    width: 1,
                  )),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
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