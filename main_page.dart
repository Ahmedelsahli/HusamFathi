import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'alert_diaalog.dart';
import 'utils.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    getDoctors();
    super.initState();
  }

  List<String> doctorsIDs = [];
  void getDoctors() {
    setState(() {
      isLoading = true;
      doctorsData.clear();
    });

    FirebaseFirestore db = FirebaseFirestore.instance;
    final ref;
    if (speciality.isNotEmpty) {
      ref = db
          .collection("users")
          .where("isDoctor", isEqualTo: true)
          .where('speciality', isEqualTo: speciality);
    } else if (doctorName.isNotEmpty) {
      ref = db
          .collection("users")
          .where("isDoctor", isEqualTo: true)
          .where('name', isEqualTo: doctorName);
    } else {
      ref = db.collection("users").where("isDoctor", isEqualTo: true);
    }

    ref.get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          if (docSnapshot.id != FirebaseAuth.instance.currentUser!.uid) {
            doctorsIDs.add(docSnapshot.id);
            doctorsData.add(docSnapshot.data());
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

  String speciality = '';
  String doctorName = '';
  bool isLoading = true;
  final TextEditingController _textFieldController = TextEditingController();
  List<Map<String, dynamic>> doctorsData = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'استكشاف',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Builder(builder: (context) {
                      List<Widget> children = [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'الرجاء اختيار التخصص',
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ),
                        ListTile(
                          selected: speciality == '',
                          onTap: () {
                            speciality = '';
                            getDoctors();
                            Navigator.pop(context);
                          },
                          title: const Text('الكل'),
                        ),
                      ];
                      for (var item in specialityItems) {
                        children.add(
                          ListTile(
                            selected: speciality == item,
                            onTap: () {
                              doctorName = '';
                              speciality = item;
                              getDoctors();
                              Navigator.pop(context);
                            },
                            title: Text(item),
                          ),
                        );
                      }
                      return Column(children: children);
                    }),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: AlertDialog(
                      title: const Text('البحث باسم الدكتور'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _textFieldController,
                            decoration:
                                const InputDecoration(hintText: "اسم الدكتور"),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      speciality = '';
                                      doctorName = _textFieldController.text;
                                      getDoctors();
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'بحث',
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                    5.0,
                                  ),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('الغاء'),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Builder(builder: (context) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (doctorsData.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد بيانات لعرضها',
            ),
          );
        }
        return ListView.builder(
          itemCount: doctorsData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          doctorsData[index]['name'],
                        ),
                        subtitle: Text(
                          doctorsData[index]['speciality'],
                        ),
                      ),
                      const Text(
                        "ايام الحجز",
                      ),
                      Builder(builder: (context) {
                        List<Widget> children = [];
                        for (var i in doctorsData[index]['doctorDays']) {
                          children.add(
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                'تأكيد الحجز',
                                                style: TextStyle(
                                                  fontSize: 25,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            Text(
                                              "${'هل تريد تأكيد الحجز عند الدكتور :' + doctorsData[index]['name']} في يوم  " +
                                                  i,
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      5.0,
                                                    ),
                                                    child: ElevatedButton(
                                                      onPressed: () async {
                                                        FirebaseFirestore db =
                                                            FirebaseFirestore
                                                                .instance;

                                                        String userID =
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid;
                                                        String doctorID =
                                                            doctorsIDs[index];

                                                        final ref = db
                                                            .collection('users')
                                                            .doc(userID);
                                                        final userData =
                                                            (await ref.get())
                                                                .data()!;
                                                        final oldUserResrvation = (await db
                                                                    .collection(
                                                                        'reservation')
                                                                    .doc(userID)
                                                                    .get())
                                                                .data() ??
                                                            {};
                                                        for (var rev
                                                            in oldUserResrvation
                                                                .values) {
                                                          if (rev['doctorID'] ==
                                                              doctorID) {
                                                            log('error you can not reserve');
                                                            if (!mounted) {
                                                              return;
                                                            }
                                                            Navigator.pop(
                                                                context);
                                                            var snackBar =
                                                                const SnackBar(
                                                              backgroundColor:
                                                                  Colors.red,
                                                              content: Text(
                                                                'خطأ لا يمكنك حجز لديك بالفعل حجز على هذا الطبيب',
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    snackBar);

                                                            return;
                                                          }
                                                        }
                                                        log(oldUserResrvation
                                                            .toString());
                                                        final oldDoctorResrvation = (await db
                                                                    .collection(
                                                                        'reservation')
                                                                    .doc(
                                                                        doctorID)
                                                                    .get())
                                                                .data() ??
                                                            {};
                                                        final reservationData =
                                                            {
                                                          'doctorID': doctorID,
                                                          'pationtID':
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                          "doctorName":
                                                              doctorsData[index]
                                                                  ['name'],
                                                          "speciality":
                                                              doctorsData[index]
                                                                  [
                                                                  'speciality'],
                                                          "pationtName":
                                                              userData['name'],
                                                          "pationtPhoneNumber":
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .phoneNumber,
                                                          'pationtGander':
                                                              userData[
                                                                  'gander'],
                                                          'reservationDay': i
                                                        };
                                                        oldUserResrvation[
                                                                DateTime.now()
                                                                    .toString()] =
                                                            reservationData;
                                                        oldDoctorResrvation[
                                                                DateTime.now()
                                                                    .toString()] =
                                                            reservationData;
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'reservation')
                                                            .doc(userID)
                                                            .set(
                                                                oldUserResrvation);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'reservation')
                                                            .doc(doctorID)
                                                            .set(
                                                              oldDoctorResrvation,
                                                            );
                                                        var snackBar =
                                                            const SnackBar(
                                                          backgroundColor:
                                                              Colors.green,
                                                          content: Text(
                                                            'تم إتمام الحجز الخاص بك بنجاح',
                                                            textAlign:
                                                                TextAlign.right,
                                                          ),
                                                        );
                                                        if (!mounted) {
                                                          return;
                                                        }
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                snackBar);
                                                      },
                                                      child: const Text(
                                                        'تاكيد',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      5.0,
                                                    ),
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('الغاء'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 50,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  i,
                                ),
                              ),
                            ),
                          );
                        }
                        return Row(
                          children: children,
                        );
                      })
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
