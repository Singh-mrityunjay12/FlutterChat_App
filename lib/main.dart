import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/model/firebasehelper.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:chat_app/pages/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uid1 =
    Uuid(); //ye id global h ham apne app ke kisi bhi page per use kar skate h

// UserModel userModel = UserModel(); //isaka use kar skate the
void main() async {
  // UserModel userModel = UserModel();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //main function ke inside ham chacke karenge ki mera app logged in h or nahi
  User? currentUser = FirebaseAuth.instance
      .currentUser; //Returns the current [User] if they are currently signed-in, or null if not.
  if (currentUser != null) {
    //logged in
    //ab hame yaha userModel ki jarurat h yaha per ham firebse se data fetch karenge aur UserModel.fromMap(Map<String, dynamic> toMap) isaki help object banayege
    //isake ak alag FirebseModel ke name ak file banayege jisase kahi aur jarurat ho to ham use kar seke
    UserModel? thisuserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisuserModel != null) {
      runApp(
          MyAppLoggedIn(userModel: thisuserModel, firebaseUser: currentUser));
    } else {
      runApp(MyApp());
    }
  } else {
    //not logged in

    runApp(MyApp());
  }
}

//My App is not LoggedIn tab ye instance use karate h(means koi signup na kiya ho to)
class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

//Another instance of MyApp
////My App is  LoggedIn tab ye instance use karate h(means koi signup  kiya ho to or Already Logged in)
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MyAppLoggedIn(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}
