import 'package:flutter/material.dart';

class UIHelper {
  static void showLoadingDialog(BuildContext context, String title1) {
    AlertDialog loadingDialog = AlertDialog(
      content: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            Text(title1),
          ],
        ),
      ),
    );
    //show alert dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return loadingDialog;
        });
  }

  static void showAlertDialog(
      BuildContext context, String title1, String content) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title1),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Center(
                child: Text(
              "Ok",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )))
      ],
    );
    showDialog(
        context: context,
        builder: (context) {
          return alertDialog;
        });
  }
}
