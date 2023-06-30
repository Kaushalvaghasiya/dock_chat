import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatRoom extends StatelessWidget {

  final TextEditingController _message = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String currUser="user1";

  final List<Map<String, dynamic>> dummyChat=[
    {
      "message":"User1 created this group",
      "type":"notify",
    },
    {
      "message":"hello",
      "sendby":"user1",
      "type":"text",
    },
    {
      "message":"hello",
      "sendby":"user2",
      "type":"text",
    },
    {
      "message":"User1 added user4",
      "type":"notify",
    },
    {
      "message":"hello",
      "sendby":"user1",
      "type":"text",
    },
    {
      "message":"hello",
      "sendby":"user4",
      "type":"text",
    },
  ];
  
  GroupChatRoom({super.key});

  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton (icon: Icon(Icons.more_vert), onPressed: () {}),
        ],
      //   title: StreamBuilder<DocumentSnapshot>(
      //   // stream: _firestore.collection("users").doc(userMap["uid"]).snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.data != null) {
      //       return Row(
      //         children: [
      //           CircleAvatar(
      //             child: Text("0"),
      //           ),
      //           Center(
      //             child: Column(
      //               children: [
      //                 Text("Group name"),
      //                 Text(
      //                   snapshot.data?['status'],
      //                   style: TextStyle(fontSize: 14),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ],
      //       );
      //     } else {
      //       return Container();
      //     }
      //   },
      // )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                   return messageTile(context, size, dummyChat[index]);
                },
            ),
          ),
            // Container(
            //   height: size.height / 1.25,
            //   width: size.width,
            //   child: StreamBuilder<QuerySnapshot>(
            //     stream: _firestore
            //         .collection("chatroom")
            //         .doc(chatRoomId)
            //         .collection("chats")
            //         .orderBy("time", descending: false)
            //         .snapshots(),
            //     builder: (BuildContext context,
            //         AsyncSnapshot<QuerySnapshot> snapshot) {
            //       if (snapshot.data != null) {
            //         return ListView.builder(
            //           itemCount: snapshot.data?.docs.length,
            //           itemBuilder: (context, index) {
            //             Map<String, dynamic> map = snapshot.data?.docs[index]
            //                 .data() as Map<String, dynamic>;
            //             return messages(context, size, map);
            //           },
            //         );
            //       } else {
            //         return Container();
            //       }
            //     },
            //   ),
            // ),
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
              IconButton(
                  onPressed: (){},
                  icon: Icon(
                    Icons.photo,
                    size: 35,
                  )),
              Container(
                height: size.height / 16,
                width: size.width / 1.5,
                child: TextField(
                  controller: _message,
                  decoration: InputDecoration(
                    hintText: "Send Message",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(
                  onPressed: (){},
                  icon: Icon(
                    Icons.send,
                    size: 35,
                  )),
            ],
          ),
        ),
      ),
    );
  }
  Widget messageTile(BuildContext context, Size size, Map<String, dynamic> map) {
    return Builder(builder: (_){
        if (map["type"]=="notify"){
          return Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromARGB(255, 202, 203, 202)),
              child: Text(
                map["message"],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
            ),
          );
        }
        else if(map["type"] == "text"){
          return Container(
            width: size.width,
            alignment: (map["sendby"] == currUser)
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.deepPurple),
              child: Column(
                children: [
                    Text(
                      map["sendby"],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      map["message"],
                      style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }else if(map["type"] == "img"){
          return InkWell(
            onTap: (){},
            child: Container(
                height: size.height / 2.5,
                width: size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                alignment: (map["sendby"] == _auth.currentUser?.email.toString())
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  height: size.height / 2.5,
                  width: size.width / 2,
                  decoration: BoxDecoration (border: Border.all()),
                  alignment: Alignment.center,
                  child: Image.network(
                    map["message"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Failed to load image');
                    },
                  ),
                ),
              ),
          );
        }
        else{
          return Container();
        }
      }
    );
  }
}