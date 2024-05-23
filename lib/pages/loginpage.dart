import 'package:chat_app/model/UIhelper.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/signuppage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

import '../model/usermodel.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  void checkValue() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the Field");
    } else {
      loginUp(email, password);
    }
  }

  void loginUp(String email, String password) async {
    //FirebaseAuth hame Ak UserCredential class provide katata h
    UserCredential? credential;
    UIHelper.showLoadingDialog(context, "Loading...");
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      //for closing loading dialog
      Navigator.pop(context);
      //for showing alert
      UIHelper.showAlertDialog(
          context, "An error ocuured", ex.message.toString());
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      //here DocumentSnapshot ak class h FirebaseFirestore ka jisaka use karake ham ak object create karate here jisaka name userData h
      //here ham log firebase se data fetch kar rahe h
      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      UserModel
          userModel = //as keyword ka use karake ham data() ko map convert karate h jise userModel me store karate h
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Get.snackbar("Login user ", "Login Up is Successfully!",
          snackPosition: SnackPosition.BOTTOM);

      print("Login is Successfully");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebaseUser: credential!.user!);
      }));
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
                height: 20,
              ),
              CupertinoButton(
                  child: Text(
                    "Log In",
                  ),
                  onPressed: () {
                    checkValue();
                  },
                  color: Theme.of(context).colorScheme.secondary)
            ],
          )),
        ),
      )),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 16),
          ),
          CupertinoButton(
              child: Text("Sign up"),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SignUpPage();
                }));
              })
        ]),
      ),
    );
  }
}
