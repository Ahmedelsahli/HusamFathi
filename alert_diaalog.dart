import 'package:flutter/material.dart';

Future<void> showAlertDialog(
    String title, String message, BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Directionality(
            textDirection: TextDirection.rtl, child: Text(title)),
        content: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('تم'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
