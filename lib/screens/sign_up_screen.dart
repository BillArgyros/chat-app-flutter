import 'package:flutter/material.dart';

import '../services/authentication.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final AuthServices _authServices = AuthServices();

  String email = '';
  String password = '';
  bool visibility = false;
  String phone = '';
  String name = '';
  bool error = false;
  List<dynamic> cart = [];
  List<dynamic> bookMark = [];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(229, 229, 229, 1),
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SizedBox(
              width: screenWidth * 1,
              height: screenHeight * 0.1,
            ),
            // create a form responsible for validating the proper format of the users information
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.5,
                    child: Card(
                      elevation: 10,
                      color: const Color.fromRGBO(229, 229, 229, 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _textFieldName(context, screenWidth, screenHeight),
                          _textFieldEmail(context, screenWidth, screenHeight),
                          Stack(
                            children: [
                              _textFieldPassword(
                                  context, screenWidth, screenHeight),
                              Container(
                                padding:
                                const EdgeInsets.only(right: 20),
                              //  width: screenWidth * 0.8,
                                height: screenHeight * 0.06,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: _passwordIcon(),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: screenWidth * 1,
                    height: screenHeight * 0.03,
                  ),
                  _signUpButton(context, screenWidth, screenHeight),
                  const Text('OR',style: TextStyle(color: Colors.black,fontSize: 12,fontWeight: FontWeight.bold),),
                  _logInButton(context, screenWidth, screenHeight),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 30),
              child: Container(
                width: screenWidth * 0.6,
                child: const Text(
                  'Create new account',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: error? const Text('Invalid Email Format',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)):Text(''),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _textFieldName(
      BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.09,
          child: TextFormField(
            validator: (text) =>
            text!.isEmpty ? 'Please enter your name' :null,
            onChanged: (text) => name = text,
            decoration: const InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              labelText: 'Name',
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldEmail(
      BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.09,
          child: TextFormField(
            validator: (text) => text!.isEmpty?'Please enter a valid email' :null,
            onChanged: (text) => email = text,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  vertical: 10.0, horizontal: 10.0),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
              labelText: 'email',
            ),
          ),
        ),
      ),
    );
  }

  Widget _textFieldPassword(
      BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.09,
          child: TextFormField(
              validator: (text) =>
              text!.length < 6 ? 'Password must be 6+ chars' : null,
              onChanged: (text) => password = text,
              decoration: const InputDecoration(
                contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                labelText: 'password',
              ),
              obscureText: visibility ? false : true),
        ),
      ),
    );
  }

  //if this icon is pressed the visibility of the password  field changes
  Widget _passwordIcon() {
    if (visibility) {
      return IconButton(
          onPressed: () {
            setState(() {
              visibility = false;
            });
          },
          icon: const Icon(Icons.visibility_outlined));
    } else {
      return IconButton(
          onPressed: () {
            setState(() {
              visibility = true;
            });
          },
          icon: const Icon(Icons.visibility_off_outlined));
    }
  }

  Widget _signUpButton(context, screenWidth, screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 1))]),
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        child: TextButton(
          onPressed: () async {
            //when the button is pressed, check the validity of the form
            if (_formKey.currentState!.validate()) {
              dynamic result= await _authServices.registerWithEmailAndPassword(
                  email, password, name);
              //if the database fails to create a new user the error boolean becomes true and the user is being informed that the email is not proper
              if(result==null){
                setState(() {
                  error=true;
                });
              }else{
                Navigator.pop(context);
              }
            }
          },
          child: const FittedBox(
              child: Text(
                'Sign Up',
                style: TextStyle(color: Colors.black, fontSize: 15),
              )),
        ),
      ),
    );
  }

  Widget _logInButton(context, screenWidth, screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 1))]),
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        child: TextButton(
          onPressed: () async {
           Navigator.pop(context);
          },
          child: const FittedBox(
              child: Text(
                'Back to log in',
                style: TextStyle(color: Colors.black, fontSize: 15),
              )),
        ),
      ),
    );
  }

}
