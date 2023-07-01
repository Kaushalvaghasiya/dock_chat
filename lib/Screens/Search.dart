import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dock_chat/Methods.dart';
import 'package:dock_chat/Screens/Group/CreateGroup.dart';
import 'package:dock_chat/Screens/Group/GroupChatRoom.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'User/ChatRoom.dart';

List? users;
class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> with WidgetsBindingObserver {
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async{
    await _firestore.collection("users").doc(_auth.currentUser?.uid).update({"status": status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state==AppLifecycleState.resumed){
      setStatus("Online");
    }else{
      setStatus("Offline");
    }
  }

  String chatRoomId (String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] > user2.toLowerCase().codeUnits[0]) {
        return "$user1$user2";
    }else{ return "$user2$user1";}
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text ("Home Docks"),
        actions: [
          IconButton (icon: const Icon(Icons.logout_rounded), onPressed: () => logOut(context)),
        ],
      ),
      body: Column(children: [
        SizedBox(
          height: size.height / 100,
        ),
        Container(
          height: size.height / 19,
          width: size.width,
          alignment: Alignment.center,
          child: SizedBox(
            height: size.height,
            width: size.width / 1.1 ,
            child: TextField(
              controller: _search,
              decoration: InputDecoration ( 
              hintText: "Search",
              hintStyle: const TextStyle (color: Colors.grey), border: OutlineInputBorder (
                borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.uid).collection("groups").snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error = ${snapshot.error}');
            if (snapshot.hasData) {
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  final data = docs[i].data();
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Text("0"),
                      ),
                      subtitle: const Text('Item description'),
                      trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.more_vert)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => GroupChatRoom(data)));
                      },
                      title: Text(data['email']),
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (_, snapshot) {
            if (snapshot.hasError) return Text('Error = ${snapshot.error}');
            if (snapshot.hasData) {
              final docs = snapshot.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (_, i) {
                  final data = docs[i].data();
                  if (data["email"] == _auth.currentUser?.displayName){
                    return Container();
                  }else{
                    return Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Text("0"),
                        ),
                        subtitle: const Text('Item description'),
                        trailing: IconButton(onPressed:(){
                        }
                        ,icon:const Icon(Icons.more_vert)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        onTap: () {
                          String? disnameq = _auth.currentUser?.displayName;
                          String disname = disnameq ?? "0";
                          String roomId = chatRoomId(disname, data["email"]);
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatRoom(roomId, data)
                          ));
                          },
                        title: Text(data['email']),
                      ),
                    );
                  }
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
       ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.group_add),
        onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateGroup(),),),
      ),
    );
  }
}