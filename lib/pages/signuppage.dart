import 'package:chat_app/model/UIhelper.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:chat_app/pages/completeprofilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cpasswordController = TextEditingController();

  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cpassword = cpasswordController.text.trim();
    if (email == "" || password == "" || cpassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the Field");
    } else if (password != cpassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The Password you entered do not match");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    //FirebaseAuth hame Ak UserCredential class provide katata h
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Created New Account....");
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      //for closing loading dialog
      Navigator.pop(context);
      //for showing alert
      UIHelper.showAlertDialog(
          context, "An error ocuured", ex.message.toString());
    }
    if (credential != null && credential.user != null) {
      String uid = credential.user!.uid;
      UserModel createUser =
          UserModel(uid: uid, fullName: "", email: email, profilePic: "");
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(createUser.toMap())
          .then((value) {
        Get.snackbar("New User Created ", "Sign Up is Successfully!",
            snackPosition: SnackPosition.BOTTOM);
        print("New User Created");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return CompleteProfile(
              userModel: createUser,
              firebseUser: credential!
                  .user!); //! ye sign chack karata h ki jo variable ho skata h vo null to nahi h
        }));
      });
    } else {
      Get.snackbar("Error", "Null check operator used on a null value",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Text(
                "Chat App",
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password"),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: cpasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "ConfermPassword"),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                  child: Text(
                    "Sign Up",
                  ),
                  onPressed: () {
                    checkValue();
                    //   Navigator.push(context,
                    //       MaterialPageRoute(builder: (context) {
                    //     return CompleteProfile(
                    //         userModel: widget.userModel,
                    //         firebseUser: widget.firebaseUser);
                    //   }));
                  },
                  color: Theme.of(context).colorScheme.secondary)
            ],
          )),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Allready have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: Text("Log In"),
              onPressed: () {
                Navigator.pop(
                    context); //signUpPage ko pop(remove) karane ke liye use karate h
              })
        ]),
      ),
    );
  }
}
