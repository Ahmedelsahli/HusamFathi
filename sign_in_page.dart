import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hostepil1200/utils.dart';

import 'alert_diaalog.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isSendigCode = false;
  bool isVarifying = false;
  bool codeIsSent = false;
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  late String verificationId;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: kPrimaryColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Image.asset('assets/images/splash_icon.jpg'),
                    Card(
                      elevation: 18,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                            TextField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف',
                                hintText: '09xxxxxxxx',
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            isSendigCode == false
                                ? TextButton(
                                    onPressed: () async {
                                      if (_phoneNumberController.text.length ==
                                          10) {
                                        log('send sms code');
                                        setState(() {
                                          isSendigCode = true;
                                        });

                                        await FirebaseAuth.instance
                                            .verifyPhoneNumber(
                                          phoneNumber:
                                              '+218${_phoneNumberController.text.substring(1)}',
                                          verificationCompleted:
                                              (PhoneAuthCredential credential) {},
                                          verificationFailed:
                                              (FirebaseAuthException e) {
                                            log(e.toString());
                                            log('error');
                                            setState(() {
                                              isSendigCode = false;
                                            });
                                          },
                                          codeSent: (String verificationId,
                                              int? resendToken) {
                                            log(verificationId);
                                            this.verificationId = verificationId;
                                            setState(() {
                                              isSendigCode = false;
                                            });
                                          },
                                          codeAutoRetrievalTimeout:
                                              (String verificationId) {},
                                        );
                                      } else {
                                        showAlertDialog(
                                            "الرجاء التحقق من الرقم",
                                            "الرجاء كتابة الرقم كاملا بشكل صحيح",
                                            context);
                                      }
                                    },
                                    child: const Text(
                                      'الحصول علي الرمز',
                                    ),
                                  )
                                : const CircularProgressIndicator(),
                            TextField(
                              keyboardType: TextInputType.phone,
                              controller: _smsCodeController,
                              onChanged: (value) {
                                if (value.isNotEmpty &&
                                    _phoneNumberController.text.length == 10) {
                                  codeIsSent = true;
                                } else {
                                  codeIsSent = false;
                                }
                                setState(() {});
                              },
                              decoration: const InputDecoration(
                                labelText: 'الرمز',
                                hintText: 'xxxxxx',
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            codeIsSent
                                ? isVarifying == false
                                    ? ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            isVarifying = true;
                                          });

                                          try {
                                            FirebaseAuth auth =
                                                FirebaseAuth.instance;

                                            // Create a PhoneAuthCredential with the code
                                            PhoneAuthCredential credential =
                                                PhoneAuthProvider.credential(
                                              verificationId: verificationId,
                                              smsCode: _smsCodeController.text,
                                            );

                                            // Sign the user in (or link) with the credential
                                            await auth
                                                .signInWithCredential(credential);
                                          } catch (e) {
                                            log('error');
                                            showAlertDialog(
                                                "الرجاء التحقق من الرمز",
                                                "الرجاء التحقق من صحه الرمز",
                                                context);
                                          }

                                          setState(() {
                                            isVarifying = false;
                                          });
                                        },
                                        child: const Text(
                                          'التاكد من الرمز',
                                        ),
                                      )
                                    : const CircularProgressIndicator()
                                : const SizedBox(),
                            const SizedBox(
                              height: 25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
