import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'package:provider/provider.dart';


class Wrapper extends StatefulWidget {
  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  @override
  Widget build(BuildContext context) {
   final user = Provider.of<UserModel?>(context);
    //check if there is a user logged in
    if(user==null){
      return  LoginScreen();
    }else{
       return  HomeScreen();
    }

  }
}
