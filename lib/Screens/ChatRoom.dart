import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatelessWidget {
  final TextEditingController _message = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String chatRoomId;
  final Map<String, dynamic> userMap;

  ChatRoom(this.chatRoomId, this.userMap);

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    Uint8List imageData = await XFile(pickedFile!.path).readAsBytes();

    uploadImage(imageData);
  }

  Future<String> uploadImage(Uint8List xfile) async {
    var _storage = FirebaseStorage.instance;
    Reference ref = _storage.ref().child("images");
    String id = const Uuid().v1();
    ref = ref.child(id);

    UploadTask uploadTask = ref.putData(
      xfile,
      SettableMetadata(contentType: 'image/jpg'),
    );
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    await _firestore
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(id).set({
      "sendby": _auth.currentUser?.email.toString(),
      "message": downloadUrl,
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    return downloadUrl;
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser?.email.toString(),
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };
      _message.clear();
      await _firestore
          .collection("chatroom")
          .doc(chatRoomId)
          .collection("chats")
          .add(messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
          title: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("users").doc(userMap["uid"]).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xff764abc),
                  child: Text("0"),
                ),
                Center(
                  child: Column(
                    children: [
                      Text(userMap["email"]),
                      Text(
                        snapshot.data?['status'],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      )),
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
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data?.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(context, size, map);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
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
              IconButton(
                  onPressed: getImage,
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
                  onPressed: () => onSendMessage(),
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

  Widget messages(BuildContext context, Size size, Map<String, dynamic> map) {

    return map["type"] == "text"
        ? Container(
            width: size.width,
            alignment: (map["sendby"] == _auth.currentUser?.email.toString())
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.deepPurple),
              child: Text(
                map["message"],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        : InkWell(
          onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ShowImage(imageUrl: map["message"]))),
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
}
class ShowImage extends StatelessWidget {
  final String imageUrl;
  const ShowImage({required this.imageUrl, Key? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of (context) .size;
    return Scaffold(
      body: Container(
      height: size.height, 
      width: size.width, 
      color: Colors.black, 
      child: Image.network(imageUrl),
      ),
    );
  }
}