import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alert_diaalog.dart';
import 'utils.dart';

class ReverstionPage extends StatefulWidget {
  const ReverstionPage({super.key});

  @override
  State<ReverstionPage> createState() => _ReverstionPageState();
}

class _ReverstionPageState extends State<ReverstionPage> {
  @override
  void initState() {
    getReservation();
    super.initState();
  }

  bool isLoading = true;
  bool isDoctor = false;
  Map<String, Map<String, dynamic>> reservationList = {};
  List<String> dates = [];
  Future<void> getReservation() async {
    setState(() {
      isLoading = true;
      reservationList.clear();
    });

    FirebaseFirestore db = FirebaseFirestore.instance;
    String userUID = FirebaseAuth.instance.currentUser!.uid;
    final DocumentReference<Map<String, dynamic>> ref =
        db.collection("reservation").doc(userUID);
    isDoctor =
        (await db.collection("users").doc(userUID).get()).data()!['isDoctor'];
    ref.get().then(
      (querySnapshot) {
        if (querySnapshot.data() != null) {
          for (var docSnapshot in querySnapshot.data()!.entries) {
            reservationList[docSnapshot.key] = (docSnapshot.value);
          }
        }

        setState(() {
          isLoading = false;
        });
      },
      onError: (e) {
        setState(() {
          isLoading = false;
        });
        showAlertDialog(
            'خطا في الاتصال', "الرجاء التحقق من اتصالك بالانترنت", context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: isDoctor == true ? 2 : 1,
      child: Builder(builder: (context) {
        List<Widget> children = [
          Builder(builder: (context) {
            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
                itemCount: reservationList.length,
                itemBuilder: (context, index) {
                  if (reservationList.values.toList()[index]['doctorID'] ==
                      FirebaseAuth.instance.currentUser!.uid) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Card(
                      elevation: 12,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '  الدكتور:  ' +
                                  reservationList.values.toList()[index]
                                      ['doctorName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              'التخصص:  ' +
                                  reservationList.values.toList()[index]
                                      ['speciality'],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Text(
                              'يوم الحجز:  :  ${toFullDayName(reservationList.values.toList()[index]['reservationDay'])}',
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () async {
                                  try {
                                    FirebaseFirestore db =
                                        FirebaseFirestore.instance;
                                    // Delete from user
                                    final patRef = db
                                        .collection("reservation")
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid);

                                    final oldUserData =
                                        (await patRef.get()).data()!;
                                    oldUserData.remove(
                                        reservationList.keys.toList()[index]);
                                    patRef.set(oldUserData);

                                    // Delete from doctor
                                    final docRef = db
                                        .collection("reservation")
                                        .doc(reservationList.values
                                            .toList()[index]['doctorID']);
                                    // log(reservationList.values
                                    //     .toList()[index]['doctorID']
                                    //     .toString());
                                    final oldDoctorData =
                                        (await docRef.get()).data()!;
                                    log(oldDoctorData.length.toString());
                                    // log(index.toString());
                                    Map<String, dynamic> tempMap = {};
                                    oldDoctorData.forEach((k, v) {
                                      log(v['doctorID'].toString());
                                      log(reservationList.values
                                          .toList()[index]['doctorID']
                                          .toString());
                                      log((v['doctorID'] !=
                                              reservationList.values
                                                  .toList()[index]['doctorID'])
                                          .toString());
                                      if (v['doctorID'] !=
                                          reservationList.values.toList()[index]
                                              ['doctorID']) {
                                        log((v['doctorID'].toString() ==
                                                reservationList.values
                                                        .toList()[index]
                                                    ['doctorID'])
                                            .toString());
                                        tempMap[k] = v;
                                      }
                                    });

                                    // for (var k  v in oldDoctorData.entries){
                                    // if (v==)
                                    //  }
                                    //  oldDoctorData.removeWhere((key, value) =>
                                    // value ==
                                    // reservationList.values.toList()[index]);
                                    log(tempMap.length.toString());

                                    log('#########################################');

                                    docRef.set(tempMap);

                                    // refrish UI
                                    getReservation();

                                    var snackBar = const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        'تم حذف الحجز',
                                        textAlign: TextAlign.right,
                                      ),
                                    );
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } catch (e) {
                                    showAlertDialog(
                                      'خطا في الاتصال',
                                      "الرجاء التحقق من اتصالك بالانترنت",
                                      context,
                                    );
                                  }
                                },
                                child: const Text('الغاء الحجز'),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }),
        ];
        List<Widget> tabs = [
          Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_upward),
                SizedBox(
                  width: 12,
                ),
                Text('حجوزاتي')
              ],
            ),
          ),
        ];
        if (isDoctor == true) {
          children.add(
            Builder(builder: (context) {
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: reservationList.length,
                  itemBuilder: (context, index) {
                    if (reservationList.values.toList()[index]['doctorID'] !=
                        FirebaseAuth.instance.currentUser!.uid) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        elevation: 12,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '  المريض:  ' +
                                    reservationList.values.toList()[index]
                                        ['pationtName'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const Divider(),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                'رقم الهاتف:  ' +
                                    reservationList.values.toList()[index]
                                        ['pationtPhoneNumber'],
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                'يوم الحجز:  :  ${toFullDayName(reservationList.values.toList()[index]['reservationDay'])}',
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                'الجنس :  :  ${reservationList.values.toList()[index]['pationtGander']}',
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            FirebaseFirestore db =
                                                FirebaseFirestore.instance;
                                            // Delete from user
                                            final patRef = db
                                                .collection("reservation")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid);

                                            final oldUserData =
                                                (await patRef.get()).data()!;
                                            oldUserData.remove(reservationList
                                                .keys
                                                .toList()[index]);
                                            patRef.set(oldUserData);
                                            // Delete from doctor
                                            final docRef = db
                                                .collection("reservation")
                                                .doc(reservationList.values
                                                        .toList()[index]
                                                    ['doctorID']);
                                            // log(reservationList.values
                                            //     .toList()[index]['doctorID']
                                            //     .toString());
                                            final oldDoctorData =
                                                (await docRef.get()).data()!;
                                            log(oldDoctorData.length
                                                .toString());
                                            // log(index.toString());
                                            Map<String, dynamic> tempMap = {};
                                            oldDoctorData.forEach((k, v) {
                                              log(v['doctorID'].toString());
                                              log(reservationList.values
                                                  .toList()[index]['doctorID']
                                                  .toString());
                                              log((v['doctorID'] !=
                                                      reservationList.values
                                                              .toList()[index]
                                                          ['doctorID'])
                                                  .toString());
                                              if (v['doctorID'] !=
                                                      reservationList.values
                                                              .toList()[index]
                                                          ['doctorID'] ||
                                                  v['pationtID'] !=
                                                      reservationList.values
                                                              .toList()[index]
                                                          ['pationtID']) {
                                                log((v['doctorID'].toString() ==
                                                        reservationList.values
                                                                .toList()[index]
                                                            ['doctorID'])
                                                    .toString());
                                                tempMap[k] = v;
                                              }
                                            });

                                            // for (var k  v in oldDoctorData.entries){
                                            // if (v==)
                                            //  }
                                            //  oldDoctorData.removeWhere((key, value) =>
                                            // value ==
                                            // reservationList.values.toList()[index]);
                                            log(tempMap.length.toString());

                                            log('#########################################');

                                            docRef.set(tempMap);

                                            // refrish UI
                                            getReservation();

                                            var snackBar = const SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                'تم تأكيد الحجز وسيتم ازالته من القائمة',
                                                textAlign: TextAlign.right,
                                              ),
                                            );
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          } catch (e) {
                                            showAlertDialog(
                                              'خطا في الاتصال',
                                              "الرجاء التحقق من اتصالك بالانترنت",
                                              context,
                                            );
                                          }
                                        },
                                        child: const Text('تم الكشف'),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          try {
                                            FirebaseFirestore db =
                                                FirebaseFirestore.instance;
                                            // Delete from user
                                            final patRef = db
                                                .collection("reservation")
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid);

                                            final oldUserData =
                                                (await patRef.get()).data()!;
                                            oldUserData.remove(reservationList
                                                .keys
                                                .toList()[index]);
                                            patRef.set(oldUserData);
                                            // Delete from doctor
                                            final docRef = db
                                                .collection("reservation")
                                                .doc(reservationList.values
                                                        .toList()[index]
                                                    ['doctorID']);
                                            // log(reservationList.values
                                            //     .toList()[index]['doctorID']
                                            //     .toString());
                                            final oldDoctorData =
                                                (await docRef.get()).data()!;
                                            log(oldDoctorData.length
                                                .toString());
                                            // log(index.toString());
                                            Map<String, dynamic> tempMap = {};
                                            oldDoctorData.forEach((k, v) {
                                              log(v['doctorID'].toString());
                                              log(reservationList.values
                                                  .toList()[index]['doctorID']
                                                  .toString());
                                              log((v['doctorID'] !=
                                                      reservationList.values
                                                              .toList()[index]
                                                          ['doctorID'])
                                                  .toString());
                                              if (v['doctorID'] !=
                                                      reservationList.values
                                                              .toList()[index]
                                                          ['doctorID'] ||
                                                  v['pationtID'] !=
                                                      reservationList.values
                                                              .toList()[index]
                                                          ['pationtID']) {
                                                log((v['doctorID'].toString() ==
                                                        reservationList.values
                                                                .toList()[index]
                                                            ['doctorID'])
                                                    .toString());
                                                tempMap[k] = v;
                                              }
                                            });

                                            // for (var k  v in oldDoctorData.entries){
                                            // if (v==)
                                            //  }
                                            //  oldDoctorData.removeWhere((key, value) =>
                                            // value ==
                                            // reservationList.values.toList()[index]);
                                            log(tempMap.length.toString());

                                            log('#########################################');

                                            docRef.set(tempMap);

                                            // refrish UI
                                            getReservation();
                                            var snackBar = const SnackBar(
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                'تم حذف الحجز',
                                                textAlign: TextAlign.right,
                                              ),
                                            );
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          } catch (e) {
                                            showAlertDialog(
                                              'خطا في الاتصال',
                                              "الرجاء التحقق من اتصالك بالانترنت",
                                              context,
                                            );
                                          }
                                        },
                                        child: const Text('الغاء الحجز'),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }),
          );
          tabs.add(Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_downward),
                SizedBox(
                  width: 12,
                ),
                Text('حجزات المرضي')
              ],
            ),
          ));
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('الحجوزات'),
            bottom: TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: children,
          ),
        );
      }),
    );
  }
}
