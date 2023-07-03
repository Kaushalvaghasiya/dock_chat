import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dock_chat/Methods.dart';
import 'package:dock_chat/Screens/Group/GroupInfo.dart';
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
  final String chatRoomId, uname;

  ChatRoom(this.chatRoomId, this.uname, {super.key});

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
        .collection("chatroom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(id).set({
      "sendby": _auth.currentUser?.displayName.toString(),
      "message": downloadUrl,
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });
    await _firestore
        .collection("chats")
        .doc(chatRoomId).set({
          "id": chatRoomId,
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
        .collection("chatRoom")
        .doc(chatRoomId)
        .collection("chatMessages")
        .add(messages);

      await _firestore
        .collection("chats")
        .doc(chatRoomId).set({
          "id": chatRoomId,
          "lastMessage": _message.text,
          "time": FieldValue.serverTimestamp(),
          "type": "text",
        });
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace : StreamBuilder<DocumentSnapshot>(
          stream: _firestore.collection("users").doc(uname).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.only(right: 16),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back,color: Colors.black,),
                      ),
                      const SizedBox(width: 2,),
                      const CircleAvatar(
                        backgroundImage: NetworkImage(""),
                        maxRadius: 20,
                      ),
                      const SizedBox(width: 12,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(uname, style: const TextStyle( fontSize: 16 ,fontWeight: FontWeight.w600),),
                            const SizedBox(height: 6,),
                            Text(snapshot.data?['status'],style: TextStyle(color: Colors.grey.shade600, fontSize: 13),),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.settings) ,color: Colors.black54,onPressed: (){},),
                    ],
                  ),
                ),
              );
            }else{
              return Container();
            }
          }
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
                    .collection("chatRoom")
                    .doc(chatRoomId)
                    .collection("chatMessages")
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data?.docs.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
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
                  onPressed: () => onSendMessage(),
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

  Widget messages(BuildContext context, Size size, Map<String, dynamic> map) {
    return map["type"] == "text"
        ? Container(
            width: size.width,
            alignment: (map["sendby"] == _auth.currentUser?.displayName.toString())
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color:map["sendby"] != _auth.currentUser?.displayName?const Color.fromARGB(255, 63, 63, 63):Colors.blue[200]),
              child: Text(
                map["message"],
                style: const TextStyle(
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
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              alignment: (map["sendby"] == _auth.currentUser?.displayName.toString())
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration (border: Border.all(),
                color:map["sendby"] == _auth.currentUser?Colors.grey.shade200:Colors.blue[200]),
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