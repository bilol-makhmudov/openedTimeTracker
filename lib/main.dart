import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'databaseManagement.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Milk\'s age tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

bool allow = false;
void scanBarcode() async {
  try {
    String barCode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if (barCode == "8697298011676") {
      Bottle milk = new Bottle("milk", barCode);
      milk.insertOpenedTime();
      allow = true;
    } else {
      allow = false;
    }
  } catch (e) {
    print(e);
  }
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseReference _timeRef =
      FirebaseDatabase.instance.ref().child('milk/time');
  final DatabaseReference _dayRef =
      FirebaseDatabase.instance.ref().child('milk/date');

  var day = "Today";
  var time = "00:00";
  var timePassed = "XXXX";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
            "assets/imgbin_cow-png.png",
          )),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(children: [
              Align(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: StreamBuilder<DatabaseEvent>(
                      stream: _dayRef.onValue,
                      builder:
                          (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                        day = snapshot.data?.snapshot.value.toString() ?? '';
                        return Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.black12,
                          ),
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<DatabaseEvent>(
                    stream: _timeRef.onValue,
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      time = snapshot.data?.snapshot.value.toString() ?? '';
                      return Text(
                        time,
                        style: TextStyle(fontSize: 40),
                      );
                    }),
              ),
            ]),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: GestureDetector(
                  onVerticalDragEnd: (DragEndDetails details) {
                    if (details.velocity.pixelsPerSecond.dy < 0) {
                      scanBarcode();
                      if (allow) {
                        const snackBar = SnackBar(
                          content: Text("Couldn't recognise the milk"),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.swipe_up, size: 50, color: Colors.brown),
                      Text("Swipe to add new bottle",
                          style: TextStyle(fontSize: 20, color: Colors.brown)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
