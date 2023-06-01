import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_picker/day_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;

import 'alert_diaalog.dart';
import 'utils.dart';

class UserDataPage extends StatefulWidget {
  final String name;
  final String birthdate;
  final String doctorCode;
  final List<dynamic> days;
  final String gander;
  final String speciality;
  const UserDataPage(
      {super.key,
      required this.name,
      required this.days,
      required this.birthdate,
      required this.doctorCode,
      required this.gander,
      required this.speciality});

  @override
  State<UserDataPage> createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  @override
  void initState() {
    if (widget.name.isNotEmpty) {
      usrrNameController.text = widget.name;
    }
    if (widget.birthdate.isNotEmpty) {
      date = widget.birthdate;
    }
    if (widget.doctorCode.isNotEmpty) {
      doctorCode.text = widget.doctorCode;
      isDoctor = true;
    }
    if (widget.gander.isNotEmpty) {
      ganderDropdownvalue = widget.gander;
    }
    if (widget.speciality.isNotEmpty && widget.speciality != null) {
      specialityDropdownvalue = widget.speciality;
    }

    List<String> daysString = ["اح", "اث", "ث", "ار", "خ", "ج", "س"];
    for (var day in daysString) {
      _days.add(
        DayInWeek(
          day,
          isSelected: widget.days.contains(
            day,
          ),
        ),
      );
    }
    specialityDropdownvalue = widget.speciality;

    super.initState();
  }

  final TextEditingController usrrNameController = TextEditingController();
  final TextEditingController doctorCode = TextEditingController();
  String date = 'اليوم-الشهر-السنة';
  bool isDoctor = false;
  String specialityDropdownvalue = 'باطنه';
  String ganderDropdownvalue = 'ذكر';
  var ganderItems = ['ذكر', 'انثي'];

  bool isLoading = false;
  List<String> doctorDays = [];
  final List<DayInWeek> _days = [];
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'بيانات الشخصية',
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'الرجاء ادخال بيناتك الشخصية',
                      style: TextStyle(
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    'الاسم بالكامل',
                  ),
                  TextField(
                    controller: usrrNameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'الاسم ',
                      hintText: 'الاسم',
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    'الجنس',
                  ),
                  DropdownButton<String>(
                    value: ganderDropdownvalue,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: ganderItems.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        ganderDropdownvalue = newValue!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    'المواليد',
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(1995),
                          firstDate: DateTime(1950),
                          lastDate: DateTime(2100));

                      if (pickedDate != null) {
                        String formattedDate =
                            intl.DateFormat('yyyy-MM-dd').format(pickedDate);
                        setState(() {
                          date = formattedDate;
                        });
                      } else {}
                    },
                    title: Text(
                      date,
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  SwitchListTile(
                    title: const Text(
                      'هل ترغب في التسجيل كطبيب',
                    ),
                    value: isDoctor,
                    onChanged: (value) {
                      isDoctor = value;
                      setState(() {});
                    },
                  ),
                  isDoctor == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'بيانات الطبيب',
                                style: TextStyle(
                                  fontSize: 26,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              'الرقم الوظيفي',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            TextField(
                              controller: doctorCode,
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                labelText: 'الرقم الوظيفي',
                                hintText: 'الرقم الوظيفي',
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            const Text(
                              'التخصص',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            DropdownButton<String>(
                              // Initial Value
                              value: specialityDropdownvalue,

                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: specialityItems.map((String items) {
                                return DropdownMenuItem(
                                  value: items,
                                  child: Text(items),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  specialityDropdownvalue = newValue!;
                                });
                              },
                            ),
                            const Text(
                              'مواعيد التواجد',
                              style: TextStyle(
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            SelectWeekDays(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              days: _days,
                              border: false,
                              boxDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30.0),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              onSelect: (values) {
                                doctorDays = values;
                                setState(() {});
                              },
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 25,
                  ),
                  isLoading == false
                      ? Center(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              FirebaseFirestore db = FirebaseFirestore.instance;
                              final data = <String, dynamic>{
                                "name": usrrNameController.text,
                                "birthdate": date,
                                "isDoctor": isDoctor,
                                'speciality': specialityDropdownvalue,
                                'doctorCode': doctorCode.text,
                                'doctorDays': doctorDays,
                                "gander": ganderDropdownvalue,
                                'reservationList': []
                              };
                              String userID =
                                  FirebaseAuth.instance.currentUser!.uid;
                              db
                                  .collection("users")
                                  .doc(userID)
                                  .set(data)
                                  .onError((e, _) {
                                showAlertDialog(
                                  'خطا في الاتصال',
                                  "الرجاء التحقق من اتصالك بالانترنت",
                                  context,
                                );
                                return;
                              });
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'حفظ',
                            ),
                          ),
                        )
                      : const CircularProgressIndicator()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
