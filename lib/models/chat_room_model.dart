class ChatRoomModel{

  String uid;
  ChatRoomModel({required this.uid});
}


class ChatRoomData{
  String uid;
  List<dynamic> chat=[];


  ChatRoomData({required this.uid,required this.chat});
}