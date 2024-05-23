import 'package:chat_app/main.dart';
import 'package:chat_app/model/chatroommodel.dart';
import 'package:chat_app/model/messagemodel.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class chatRoomPage extends StatefulWidget {
  final UserModel
      targetModel; //jisase bat karani h means dusara user(targetUser)
  final chatroomModel chatRoom;
  final UserModel
      userModel; //for currentuser ka userModel(loggindUser) (firebase aur userModel dono same h)
  final User firebaseUser; //firebase ka user
  const chatRoomPage(
      {Key? key,
      required this.targetModel,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser})
      : super(key: key);

  @override
  State<chatRoomPage> createState() => _chatRoomPageState();
}

class _chatRoomPageState extends State<chatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController
        .clear(); //isase hoga ki TextField me jo write karate h send ke option per click karate h message vaha se clear ho jayega(The input method toggled text monitoring off)
    if (msg != null) {
      //send message
      messageModel newmessage = messageModel(
          messageId: uid1.v1(),
          sender: widget.userModel.uid,
          createdOn: DateTime.now(),
          text: msg,
          seen:
              false //seen tab tak false rahega jab tak samane vala message seen na kar le
          );
      //here ham await isliye use nahi kiye ki hame massage immediate send karana h n ki kuch time me
      //FirebaseFirestore hamara offline storage bhi support karata h incase hamara internet nahi chal raha
      //uscase ye message hamare divice per store ho jayega aur jaise hi hamara internet start hogi tab ye message
      //hamare cloud ke sath sink ho jayega aur dusare user tak pahuch jayega
      //await lagane se jab tak hamara message cloud tak nahi pahuch jayega tab tak hamara code ruk jayega
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomId)
          .collection("messages")
          .doc(newmessage.messageId)
          .set(newmessage.toMap());

      //update lastmessage
      widget.chatRoom.lastmessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatroomId)
          .set(widget.chatRoom.toMap());
      print("message send");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            backgroundImage: NetworkImage(widget.targetModel.profilePic
                .toString()), //NetworkImage isliye use karate h ki kyoki here hame url pata h image ka
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetModel.fullName.toString())
        ],
      )),
      body: SafeArea(
          child: Container(
        child: Column(
          children: [
            //This is where chat will go
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatRoom.chatroomId)
                      .collection('messages')
                      .orderBy("createdOn", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot datasnapshot =
                            snapshot.data as QuerySnapshot;
                        return ListView.builder(
                            reverse: true,
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: (context, index) {
                              messageModel currentmessage = messageModel
                                  .fromMap(datasnapshot.docs[index].data()
                                      as Map<String, dynamic>);
                              return Row(
                                mainAxisAlignment: (currentmessage.sender ==
                                        widget.userModel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 10),
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: (currentmessage.sender ==
                                                  widget.userModel.uid)
                                              ? Colors.grey
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                      child: Text(
                                          style: TextStyle(color: Colors.white),
                                          currentmessage.text.toString())),
                                ],
                              );
                            }); //yaha ham snapshot.data ko QuerySnapshot convert karenge jisase ham document me se data fecth kar sake
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              "An Error occured! Please cheak your internet connection"),
                        );
                      } else {
                        return Center(
                          child: Text("Say hi to new friend"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }), //streamBuilder ka use karake ham firebse me storage data ko app ke screen per show karate h
            )),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(children: [
                Flexible(
                    child: TextField(
                  controller: messageController,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: "Enter message", border: InputBorder.none),
                )),
                IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.secondary,
                    ))
              ]),
            )
          ],
        ),
      )),
    );
  }
}
