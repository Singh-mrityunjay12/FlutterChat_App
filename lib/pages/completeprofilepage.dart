import 'dart:io';

import 'package:chat_app/model/UIhelper.dart';
import 'package:chat_app/model/usermodel.dart';
import 'package:chat_app/pages/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/src/painting/image_provider.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel;
  final User firebseUser; //yaha jo user h vo firebaseAuth vala user h
  const CompleteProfile(
      {Key? key,
      required this.userModel,
      required this.firebseUser}) //jab ham required laga dete h to vo  variable null nahi ho skata is variable ko value to dena hi padega
      : super(key: key);

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  //hamari image picture hoti h vo ak tarah file hoti h
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
//here ImageSource ka matalab ham photo kaha  se uthana h from gallary se or from camara se
  void imageSelect(ImageSource source) async {
    XFile? pickedImage = await ImagePicker().pickImage(source: source);

    if (pickedImage != null) {
      print(
          "////////////////////////////////////////////////////////////////////////////////  picked");
      print(pickedImage);
      cropImage1(pickedImage);
    }
  }

  void cropImage1(XFile file) async {
    // ImageCropper().cropImage(sourcePath: file.path);

    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    print(
        "////////////////////////////////////////////////////////////////////////////////////////// sdfghjkmnbvcvbnmnbv");
    if (croppedImage != null) {
      print("/////////////////////////////////////////////////////////////");
      imageFile = File(croppedImage.path);
      print(
          "/////////////////////////////////////////////////////////////////////MRITYUNJAY");
    } else {
      print("///////////////////////////////////////////  file is not found");
      print(croppedImage);
    }
  }

  void checkValue() {
    String fullName = fullNameController.text.trim();
    if (fullName == "" || imageFile == null) {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the Field");
    } else {
      uploadData();
      print("Upload Data in FirebaseFirestore");
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictur") //ye profilepictur folder ka name h
        .child(widget.userModel.uid
            .toString()) //widget.userModel.uid.toString() ye picture ke file name hoga her user ki ak different id hogi
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String imageUrl = await snapshot.ref.getDownloadURL();
    String fullName = fullNameController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.profilePic = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      Get.snackbar(
          "uoploadData", "Successfully upload data on FirebaseFirestore",
          snackPosition: SnackPosition.BOTTOM);
      print("Upload Data");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return HomePage(
            userModel: widget.userModel, firebaseUser: widget.firebseUser);
      }));
    });
  }

  void showPhotoOption() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload Profile Photo"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    imageSelect(ImageSource.gallery);
                  },
                  leading: Icon(Icons.photo_album),
                  title: Text("Select form Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    imageSelect(
                        ImageSource.camera); //yaha  se hmlog argument dete h
                  },
                  leading: Icon(Icons.camera_alt),
                  title: Text("Take  from camara"),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading:
        //     false, //isase jo title me back jane vala sign hota use romove karate h
        centerTitle: true,
        title: Text("CompleteProfile"),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                onPressed: () {
                  showPhotoOption();
                },
                child: CircleAvatar(
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  radius: 60,
                  child: (imageFile == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                )),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: fullNameController,
              // obscureText: true,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            SizedBox(
              height: 20,
            ),
            CupertinoButton(
                child: Text(
                  "Submit",
                ),
                onPressed: () {
                  checkValue();
                },
                color: Theme.of(context).colorScheme.secondary)
          ],
        ),
      )),
    );
  }
}
