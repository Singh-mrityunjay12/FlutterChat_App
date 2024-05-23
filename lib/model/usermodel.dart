import 'package:flutter/foundation.dart';

class UserModel {
  String? uid;
  String? fullName; //? isaka matalab null bhi ho sakata h ye sab data
  String? email;
  String? profilePic;

  UserModel({this.uid, this.fullName, this.email, this.profilePic});

//fromMap to object use when data fetching from the server
  //ak type ka constructor h ye aur ye vo constructor jisaka use karke ham ham map se object bana sakate h
  //UserModel.fromMap(Map<String, dynamic> toMap) isako likhate hi aise h jaise kyoki hame map se object create karana h
  UserModel.fromMap(Map<String, dynamic> toMap) {
    uid = toMap['uid'];
    fullName = toMap['fullName'];
    email = toMap['email'];
    profilePic = toMap['profilePic'];
  }
  //object to map banayege jisase data ko firebase  me save kara sake firebase me data map ke formate me save hoti h
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'profilePic': profilePic
    };
  }
}
