import 'package:chat_app/loading.dart';
import 'package:flutter/material.dart';
import '../custom_paint.dart';
import '../services/authentication.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthServices _authServices = AuthServices();
  String email = '';
  String password = '';
  bool visibility = false;
  String phone = '';
  String name = '';
  bool error = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _validate = false;
  bool loading=false;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(229, 229, 229, 1),
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: screenWidth * 1,
          height: screenHeight * 1,
          child: Stack(
            children: [
              CustomPaint(
                painter: Chevron(screenHeight: screenHeight, screenWidth: screenWidth),
                child: SizedBox(
                  width: screenWidth*1,
                  height: screenHeight*0.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 20),
                child: SizedBox(
                  width: screenWidth * 0.6,
                  child: const Text(
                    'Create new account',
                    style:
                    TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.55,
                      //returns a Widget of type Card which holds the text fields and the buttons
                      child: !loading? _card(screenWidth,screenHeight):Loading(),
                    ),
                  ],
                ),
              ),
              //if the email is not properly formatted this message appears to inform the user
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: error
                      ? const Text('Invalid Email Format',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold))
                      : const Text(''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(screenWidth,screenHeight){
   return !loading? Card(
      elevation: 10,
      color: const Color.fromRGBO(229, 229, 229, 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                  child: _textFieldName(
                      context, screenWidth, screenHeight)),
              //if the validation process is active the application checks if
              // the user credentials are valid. If they are not valid, an
              //appropriate message informs the user
              _validate
                  ? _name.text.isEmpty
                  ? const Padding(
                padding: EdgeInsets.only(
                    top: 8.0, left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Name cannot be empty',
                    style: TextStyle(
                        fontSize: 8,
                        color: Colors.red),
                  ),
                ),
              )
                  : const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(),
              )
                  : const Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(),
              ),
            ],
          ),
          Container(
              child: _textFieldEmail(
                  context, screenWidth, screenHeight)),
          _validate
              ? _email.text.isEmpty
              ? const Padding(
            padding: EdgeInsets.only(
                top: 8.0, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email cannot be empty',
                style: TextStyle(
                    fontSize: 8,
                    color: Colors.red),
              ),
            ),
          )
              : const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(),
          )
              : const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(),
          ),
          Container(
              child: _textFieldPassword(
                  context, screenWidth, screenHeight)),
          _validate
              ? _password.text.length < 6
              ? const Padding(
            padding: EdgeInsets.only(
                top: 8.0, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Password must be 6+ chars',
                style: TextStyle(
                    fontSize: 8,
                    color: Colors.red),
              ),
            ),
          )
              : const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(),
          )
              : const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(),
          ),
          _signUpButton(context, screenWidth, screenHeight),
          const Text(
            'OR',
            style: TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          _logInButton(context, screenWidth, screenHeight),
        ],
      ),
    ) : Loading();
  }

  Widget _textFieldName(
      BuildContext context, double screenWidth, double screenHeight) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: SizedBox(
          width: screenWidth * 0.8,
          height: screenHeight * 0.06,
          child: TextFormField(
            controller: _name,
            onChanged: (text) => name = text,
            decoration: const InputDecoration(
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0)),
              ),
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
          height: screenHeight * 0.06,
          child: TextFormField(
            controller: _email,
            // validator: (text) => text!.isEmpty?'' :null,
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
              controller: _password,
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

  Widget _signUpButton(context, screenWidth, screenHeight) {
    //each time the user tries to sign up the validator becomes false, so that
    //the validating messages will be invisible
    if (mounted) {
      setState(() {
        _validate = false;
      });
    }
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.red.shade800,
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [BoxShadow(blurRadius: 4, offset: Offset(0, 1))]),
        width: screenWidth * 0.6,
        height: screenHeight * 0.05,
        child: TextButton(
          onPressed: () async {
            //when the button is pressed, check the validity of the data
            if (_name.text.isNotEmpty &&
                _email.text.isNotEmpty &&
                _password.text.length >= 6) {
              //if the data are appropriately formatted, the user is being
              //registered the an email and password
              setState(() {
                loading=true;
              });
              dynamic result = await _authServices.registerWithEmailAndPassword(
                  email, password, name, []);
              //if the database fails to create a new user the error boolean
              // becomes true and the user is being informed that the email is not proper
              if (result == null) {
                if (mounted) {
                  setState(() {
                    loading=false;
                    error = true;
                  });
                }
              } else {
                //if the database creates the user the screen is popped
                Navigator.pop(context);
              }
            } else {
              //if the data are not properly formatted the validator becomes true
              if (mounted) {
                setState(() {
                  _validate = true;
                });
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
            color: Colors.red.shade800,
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
