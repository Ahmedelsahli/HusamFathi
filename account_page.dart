import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alert_diaalog.dart';
import 'user_data_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    log('init state');
    getUserData();
    super.initState();
  }

  bool isLoading = true;
  Map<String, dynamic> userData = {};
  bool isDoctor = false;

  void getUserData() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userID = FirebaseAuth.instance.currentUser!.uid;
    final docRef = firestore.collection("users").doc(userID);
    docRef.get().then(
      (DocumentSnapshot doc) {
        userData = doc.data() as Map<String, dynamic>;
        setState(() {
          isDoctor = userData['isDoctor'];
          isLoading = false;
        });
      },
      onError: (e) => showAlertDialog(
        'خطا في الاتصال',
        "الرجاء التحقق من اتصالك بالانترنت",
        context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('حسابي'),
        ),
        body: Builder(builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات شخصية',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Card(
                      elevation: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'الاسم',
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              userData['name'].toString(),
                              style: const TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Divider(),
                            const Text(
                              'مواليد',
                              style: TextStyle(
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              userData['birthdate'].toString(),
                              style: const TextStyle(
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    isDoctor != false
                        ? const Text(
                            'معلومات الدكتور',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 30,
                    ),
                    isDoctor == false
                        ? const SizedBox()
                        : Card(
                            elevation: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'الرقم الوظيفي',
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    userData['doctorCode'].toString(),
                                    style: const TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  const Divider(),
                                  const Text(
                                    'التخصص ',
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    userData['speciality'].toString(),
                                    style: const TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  const Divider(),
                                  const Text(
                                    'ايام العمل',
                                    style: TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    userData['doctorDays'].join(',').toString(),
                                    style: const TextStyle(
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserDataPage(
                                birthdate: userData['birthdate'],
                                days: userData['doctorDays'],
                                gander: userData['gander'],
                                speciality: userData['speciality'],
                                doctorCode: userData['doctorCode'],
                                name: userData['name'],
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'تعديل',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                        },
                        child: const Text(
                          'تسجيل الخروج',
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
