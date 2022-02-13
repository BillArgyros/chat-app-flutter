
class UserModel{
  final String uid;

  UserModel({required this.uid});
}

class UserData{

   String uid;
   String name;
   String email;
   String password;

   UserData( { required this.email, required this.uid ,required this.password,required this.name});

}