import 'package:flutter/material.dart';

Widget signOutButton(context, screenWidth, screenHeight,_authServices) {
  return Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: TextButton.icon(
      onPressed: () {
        _authServices.signOut();
      },
      label: const Text(''),
      icon: const Icon(
        Icons.logout_outlined,
        color: Colors.black,
        size: 30,
      ),
    ),
  );
}