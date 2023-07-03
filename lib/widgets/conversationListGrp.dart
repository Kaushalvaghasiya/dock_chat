import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Screens/Group/GroupChatRoom.dart';
import '../Screens/User/ChatRoom.dart';

class ConversationListGrp extends StatefulWidget{
  String? gid;
  String? name;
  String? messageText;
  String? imageUrl;
  String? time;
  bool? isMessageRead;
  ConversationListGrp({super.key, @required this.gid,@required this.name,@required this.messageText,@required this.imageUrl,@required this.time,@required this.isMessageRead});
  @override
  _ConversationListStateGrp createState() => _ConversationListStateGrp();
}

class _ConversationListStateGrp extends State<ConversationListGrp> {
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => GroupChatRoom({"id":widget.gid,"email":widget.name})));
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16,right: 16,top: 10,bottom: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: Ink.image(
                        image: NetworkImage(widget.imageUrl!),
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        child: const InkWell(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16,),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.name??"", style: const TextStyle(fontSize: 16),),
                          const SizedBox(height: 6,),
                          Text(widget.messageText??"",style: TextStyle(fontSize: 13,color: Colors.grey.shade600, fontWeight: widget.isMessageRead!?FontWeight.bold:FontWeight.normal),),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.time!,style: TextStyle(fontSize: 12,fontWeight: widget.isMessageRead!?FontWeight.bold:FontWeight.normal),),
          ],
        ),
      ),
    );
  }
}