import 'package:chat_app/model/usermodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseHelper {
  //jab kisi method ham static bana dete h to use ham direct access kar skate aur usake jo bhi proprty or method likhe honge vo kabhi change nahi ho sakate
  static Future<UserModel?> getUserModelById(String uid) async {
    UserModel?
        userModel; //ye h null userModel UserModel null type isliye liya yadi ham jo uid denge from main fuction se yadi usase related koi user na mila to null return kara sake

    DocumentSnapshot docSnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (docSnap.data() != null) {
      userModel = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }
}
