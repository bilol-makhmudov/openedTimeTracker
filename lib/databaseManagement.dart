import 'dart:core';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Bottle {
  final DatabaseReference _milkRef =
      FirebaseDatabase.instance.ref().child("milk");
  late String name, barcode, date, time;

  Bottle(String name, String barcode) {
    String currentTime = DateFormat('HH:mm').format(DateTime.now());
    String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

    this.name = name;
    this.barcode = barcode;
    this.time = currentTime;
    this.date = currentDate;
  }

  void insertOpenedTime() {
    _milkRef.update({'time': time, "date": date}).then((_) {
      print('Fields updated successfully.');
    }).catchError((error) {
      print('Failed to update fields: $error');
    });
  }
}
