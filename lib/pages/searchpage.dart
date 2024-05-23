// ignore_for_file: prefer_is_empty

import 'dart:developer';

import 'package:chat_app/main.dart';
import 'package:chat_app/model/chatroommodel.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:chat_app/pages/chatroompage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<chatroomModel?> getChatRoomModel(UserModel targetUser) async {
    chatroomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore
        .instance //aise jitane document honge unhe ham kar lenge get
        .collection("chatrooms")
        .where("participants.${widget.firebaseUser.uid}",
            isEqualTo:
                true) //isaka matalab h ki jo current user h vo hamare chatroom  me ho
        .where("participants.${targetUser.uid}",
            isEqualTo:
                true) //target user means jo dusara particition h vo bhi hamare chatroom me ho
        .get();
    print(snapshot.docs.length);
    //ydi ham paticipate ki list type ka banate to ham do bar where nahi laga sakate but map me laga sakate h
    if (snapshot.docs.length > 0) {
      //fetch the existing one

      var docData = snapshot.docs[0].data(); //existing chatroom ka data
      chatroomModel existingChatroom =
          chatroomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = existingChatroom;
      print("Already exist one");
    } else {
      //create a new one chatroom
      //jab hamane user banaya tha FirebaseAuth se to usaki to id hame unic mil jati h

      //yaha per hame apane chatroomid ke liye aur message id ke mainualy hame ak id banani hogi jise ham log Uuid package ke help se banayenge
      chatroomModel newChatRoom = chatroomModel(
        chatroomId: uid1.v1(),
        participants: {
          widget.userModel.uid.toString():
              true, //dono me kuch problem a gayi kisi ko block karana ho to iname se kisi ak false kara denge
          targetUser.uid.toString(): true,
        },
        lastmessage: "",
        // createdOn: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatroomId)
          .set(newChatRoom.toMap());
      chatRoom = newChatRoom;

      print(
          "////////////////////////////New chatrooms created!   ${snapshot.docs.length}");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller:
                  searchController, //TextEditingController hoti usame ak text name ka ak property hoti jisase hame value milati h
              decoration: InputDecoration(labelText: "Email Addresh"),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
              child: Text("search"),
              onPressed: () {
                setState(
                    () {}); //setState lagane jo ham apane searchController me change ho change ho jayega vise hi mera build ui method phir se run hoga aur serchController ke value bhi chamge ho jayega
                //isake streamBuilder bhi chalega
              },
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: searchController.text.trim())
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                //jo bhi data ayegi ho hamari snapshot me ayegi
                if (snapshot
                        .connectionState == //active ka matalab harama connection puri tarah ban chuka h aur active h
                    ConnectionState
                        .active) //connection state se yah chake karet h ki  firebase se ham  connected h or  nahi
                {
                  if (snapshot.hasData) {
                    QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;

                    if (datasnapshot.docs.isNotEmpty) {
                      Map<String, dynamic> userMap = datasnapshot.docs[0].data()
                          as Map<String,
                              dynamic>; //hamare Firebase ak hi user ka data h isiliye docs[0] likha gaya h yadi bahut sare hote to loop ka use karana padata
                      //hame map mil gaya h to ham UserModel bana sakate h
                      UserModel searchUser = UserModel.fromMap(userMap);
                      //ye jo searchUser h hamara targetUser h jo hamare currentUser se bat karega in chatroom se
                      return ListTile(
                        onTap: () async {
                          chatroomModel? chatmodel =
                              await getChatRoomModel(searchUser);
                          if (chatmodel != null) {
                            // ignore: use_build_context_synchronously
                            Navigator.pop(
                                context); //isase yeh hoga ki jo hamara currentPage hoga vo band ho jayega jisase jab ham chatRoom page se vapas aye direct ham chat App page pahuch jaye jise home page bolate h
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                                context, //isase dusre page per chala jayega
                                MaterialPageRoute(builder: (context) {
                              return chatRoomPage(
                                  targetModel: searchUser,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  chatRoom: chatmodel);
                            }));
                          }
                        },
                        leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(searchUser.profilePic!)),
                        title: Text(searchUser.fullName!),
                        subtitle: Text(searchUser.email!),
                        trailing: Icon(Icons.keyboard_arrow_right),
                      );
                    } else {
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) {
                      //   return CompleteProfile(
                      //       userModel: widget.userModel,
                      //       firebseUser: widget.firebaseUser);
                      // }));
                      return Text(" No result found!");
                    }
                  } else if (snapshot.hasError) {
                    return SnackBar(content: Text(" An Error Occured!"));
                  } else {
                    return Text(
                        "Snapshot is Empaty that'swhy data is not found");
                  }
                } else {
                  //ydi harara connectionState  jab tak active nahi hoga tab tak circularProgressIndicator chalayenge
                  return CircularProgressIndicator();
                }
              },
            ) //yaha where ka use karake ham specific result ko show karate h from firebase se
          ],
        ),
      )),
    );
  }
}
