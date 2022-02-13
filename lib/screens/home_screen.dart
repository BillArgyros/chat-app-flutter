import 'package:chat_app/loading.dart';
import 'package:chat_app/screens/chat_room_screen.dart';
import 'package:chat_app/services/database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/authentication.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final AuthServices _authServices= AuthServices();
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    final Stream<QuerySnapshot> users =
    FirebaseFirestore.instance.collection('userInfo').snapshots();
    List<UserData> userList = [];
    final user =  Provider.of<UserModel>(context);
    return StreamBuilder(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context,snapshot) {
        return StreamBuilder<QuerySnapshot?>(
            stream: users,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data!;
                userList = createUserList(data);
                var activeUserIndex = userList.indexWhere((element) => element.uid==user.uid);
                var activeUser=userList[activeUserIndex];
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Padding(
                              padding: const EdgeInsets.only(top: 10.0,left: 10),
                              child: Text('Welcome ' + userList[activeUserIndex].name,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                            ),
                            _signOutButton(
                                context, screenWidth, screenHeight),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: SizedBox(
                            height: screenHeight*0.5,
                            child:  ListView.builder(
                              itemCount: userList.length,
                              itemBuilder: (context, index) {
                                if(userList[index].uid==user.uid){
                                  return SizedBox();
                                }else{
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Card(
                                      child: TextButton(
                                        onPressed: () {

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ChatRoom(activeUser: activeUser, secondaryUser: userList[index],)),
                                          );
                                        },
                                        child: ListTile(
                                          leading: const CircleAvatar(
                                            radius: 25.0,
                                            backgroundColor: Colors.brown,
                                          ),
                                          title: Text(userList[index].name),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                );
              } else {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Stack(
                      children: [
                        SizedBox(
                          height: screenHeight * 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: Loading(),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: _signOutButton(
                              context, screenWidth, screenHeight),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
        );
      }
    );
  }


  Widget _signOutButton(context,screenWidth,screenHeight){
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextButton.icon(
        onPressed: (){
          _authServices.signOut();
        },
        label: const Text(''),
        icon: const Icon(Icons.logout_outlined,color: Colors.black,size: 30,),
       // child: const FittedBox(child: Text("Sign out",style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold),)),
      ),
    );
  }




  List<UserData> createUserList(data){
    List<UserData> userList=[];

    for(var element in data.docs){
      UserData userData = UserData(email: element['email'], password: element['password'], name: element['name'], uid: element['uid']);
      userList.add(userData);
    }

    return userList;
  }


}
