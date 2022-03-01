import 'package:chat_app/loading.dart';
import 'package:chat_app/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import '../custom_paint.dart';
import '../services/authentication.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = '';
  String password = '';
  bool visibility = false;
  String error = '';
  final AuthServices _authServices = AuthServices();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: !loading
          ? Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: const Color.fromRGBO(229, 229, 229, 1),
              body: Stack(
                children: [
                  CustomPaint(
                    painter: Chevron(screenHeight: screenHeight, screenWidth: screenWidth),
                    child: SizedBox(
                      width: screenWidth*1,
                      height: screenHeight*0.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, left: 30),
                    child: SizedBox(
                      width: screenWidth * 0.5,
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.5,
                      child: _card(screenWidth,screenHeight),
                    ),
                  ),
                ],
              ),
            )
          : Loading(),
    );
  }

  Widget _card(double screenWidth, double screenHeight){
   return Card(
      color: const Color.fromRGBO(229, 229, 229, 1),
      elevation: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: _textFieldEmail(
                context, screenWidth, screenHeight),
          ),
          _textFieldPassword(
              context, screenWidth, screenHeight),
          SizedBox(
            width: screenWidth * 1,
            height: screenHeight * 0.02,
          ),
          //if the user enters an invalid account the error is being updated and is being displayed
          Text(
            error,
            style: const TextStyle(color: Colors.red),
          ),
          SizedBox(
            width: screenWidth * 1,
            height: screenHeight * 0.02,
          ),
          _loginButton(screenWidth, screenHeight),
          const Text(
            'OR',
            style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          _createAccButton(screenWidth, screenHeight),
          SizedBox(
            width: screenWidth * 1,
            height: screenHeight * 0.03,
          ),
        ],
      ),
    );
  }

  Widget _textFieldEmail(
      BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.06,
          child: TextFormField(
            onChanged: (text) => email = text,
            decoration: const InputDecoration(
              contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
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
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.06,
          child: TextFormField(
              onChanged: (text) => password = text,
              decoration: InputDecoration(
                suffixIcon: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () => setState(() {
                    visibility = !visibility;
                  }),
                  child: visibility
                      ? const Icon(Icons.visibility)
                      : const Icon(
                    Icons.visibility_off,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                labelText: 'password',
              ),
              obscureText: visibility ? false : true),
        ),
      ),
    );
  }

  Widget _loginButton(screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 1))]),
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        child: TextButton(
          onPressed: () async {
            //every time the login button is being pressed the error message resets
            setState(() {
              error = '';
            });
            //when the log in button is pressed the app contacts firebase and looks for a user with these credentials
            await _authServices.signInWithEmailAndPassword(email, password);
            // if there is no user the error message changes
            setState(() {
              error = 'Wrong email or password';
            });
          },
          child: const FittedBox(
              child: Text(
            'Login',
            style: TextStyle(color: Colors.black, fontSize: 15),
          )),
        ),
      ),
    );
  }

  Widget _createAccButton(screenWidth, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 1))]),
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUpScreen()),
            ).then((value) {
              if (mounted) {
                setState(() {
                  error = '';
                });
              }
            });
          },
          child: const FittedBox(
              child: Text(
            'Create new account',
            style: TextStyle(color: Colors.black, fontSize: 15),
          )),
        ),
      ),
    );
  }
}
