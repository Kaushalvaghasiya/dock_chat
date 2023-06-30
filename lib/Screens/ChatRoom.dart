import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  final TextEditingController _message = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String chatRoomId;
  final Map<String, dynamic>userMap;

  ChatRoom (this.chatRoomId, this.userMap);

  void onSendMessage() async{
    if(_message.text.isNotEmpty){
      Map<String, dynamic> messages={
        "sendby": _auth.currentUser?.email.toString(),
        "message": _message.text,
        "time": FieldValue.serverTimestamp(),
      };
      _message.clear();
      await _firestore.collection("chatroom").doc(chatRoomId).collection("chats").add(messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("users").doc(chatRoomId).snapshots(),
        builder: (context, snapshot){
          if(snapshot.data!=null){
            return Container(
              child: Column(
                children: [
                  Text(userMap["email"]),
                  Text (
                    userMap['status'],
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }else{
            return Container();
          }
        },
      )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                .collection("chatroom")
                .doc(chatRoomId)
                .collection("chats")
                .orderBy("time", descending: false)
                .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if(snapshot.data!=null){
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index){
                        Map<String, dynamic> map = snapshot.data?.docs[index].data() as Map<String, dynamic>;
                        return messages(size, map);
                      },
                    );
                  }else{
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: size.height / 17,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: size.height / 10,
        width: size.width,
        alignment: Alignment.center,
        child: Container(
          height: size.height / 12,
          width: size.width / 1.1,
          child: Row(
            children: [
              Container(
                height: size.height / 12,
                width: size.width / 1.5,
                child: TextField(
                  controller: _message,
                  decoration: InputDecoration ( 
                    hintText: "Send Message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(onPressed: () => onSendMessage(), icon: Icon(Icons.send)),
            ],
          ),
        ),
      ),
    );
  }
  Widget messages(Size size, Map<String, dynamic> map){
    return Container(
      width: size.width,
      alignment: (map["sendby"] == _auth.currentUser?.email.toString()) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.deepPurple),
        child: Text(
          map["message"],
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}