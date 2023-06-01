import 'package:flutter/material.dart';

var specialityItems = [
  'باطنه',
  'عظام',
  'جراحه عامه',
  'امراض دم',
  'اشعه',
  "مسالك",
  "امراض نساء",
  "ولادة",
  "اعصاب",
  "جلدية",
  "تحاليل"
];
Color kPrimaryColor = const Color(0xff8c1914);
Color kSecondaryColor = const Color(0xffd7a200);

String toFullDayName(String day) {
  switch (day) {
    case 'س':
      {
        return 'السبت';
      }
    case "ج":
      {
        return 'الجمعة';
      }

    case "خ":
      {
        return 'الخميس';
      }
    case "ار":
      {
        return 'الاربعاء';
      }
    case "ث":
      {
        return 'الثلاثاء';
      }
    case "اث":
      {
        return 'الاثنين';
      }
    default:
      {
        return 'الاحد';
      }
  }
}
