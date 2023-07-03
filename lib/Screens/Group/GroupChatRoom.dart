import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dock_chat/Screens/Group/GroupInfo.dart';
import 'package:dock_chat/Screens/User/ChatRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class GroupChatRoom extends StatelessWidget {

  final TextEditingController _message = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, dynamic> userMap;
  
  GroupChatRoom(this.userMap,{super.key});

  Future<void> getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    Uint8List imageData = await XFile(pickedFile!.path).readAsBytes();
    uploadImage(imageData);
  }

  Future<String> uploadImage(Uint8List xfile) async {
    FirebaseStorage _storage = FirebaseStorage.instance;
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
        .collection("groups")
        .doc(userMap["id"])
        .collection("chats")
        .doc(id).set({
      "sendby": _auth.currentUser?.displayName.toString(),
      "message": downloadUrl,
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    await _firestore
        .collection("groupChat")
        .doc(userMap["id"]).set({
          "email": userMap["email"],
          "id": userMap["id"],
          "lastMessage": downloadUrl,
          "time": FieldValue.serverTimestamp(),
          "type": "img",
        });
    return downloadUrl;
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser?.displayName.toString(),
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };
      await _firestore
          .collection("groups")
          .doc(userMap["id"])
          .collection("chats")
          .add(messages);

      await _firestore
        .collection("groupChat")
        .doc(userMap["id"]).set({
          "email": userMap["email"],
          "id": userMap["id"],
          "lastMessage": _message.text,
          "time": FieldValue.serverTimestamp(),
          "type": "text",
        });
        _message.clear();
    }
  }
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton (icon: const Icon(Icons.more_vert), onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => GroupInfo(userMap: userMap,)));
          }),
        ],
        title: Row(
          children: [
            const CircleAvatar(
              child: Text("0"),
            ),
            Center(
              child: Column(
                children: [
                  Text(userMap["email"]),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("groups")
                    .doc(userMap["id"])
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
                        return messageTile(context, size, map);
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
        child: SizedBox(
          height: size.height / 12,
          width: size.width / 1.1,
          child: Row(
            children: [
              IconButton(
                  onPressed: getImage,
                  icon: const Icon(
                    Icons.photo,
                    size: 35,
                  )),
              SizedBox(
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
                  onPressed: onSendMessage,
                  icon: const Icon(
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
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color.fromARGB(255, 202, 203, 202)),
              child: Text(
                map["message"],
                style: const TextStyle(
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
            alignment: (map["sendby"] == _auth.currentUser?.displayName.toString())
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.deepPurple),
              child: Column(
                children: [
                    Text(
                      map["sendby"],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      map["message"],
                      style: const TextStyle(
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
            onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (_)=> ShowImage(imageUrl: map["message"]))),
            child: Container(
                height: size.height / 2.5,
                width: size.width,
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                alignment: (map["sendby"] == _auth.currentUser?.displayName.toString())
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
                      return const Text('Failed to load image');
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