import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/screens/show_list.dart';
import 'package:grocery/utils/dbhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  void initState() {
    super.initState();
    _delay().then((value) => CheckedFirst());
  }

  Future<bool> _delay() async {
    await Future.delayed(Duration(seconds: 7), () {});
    return true;
  }

  Future CheckedFirst() async {
    bool visitingFlage = await getVisitingFlag();

    if (visitingFlage == true) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => ShowList()));
    } else {
      await loadItems();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => ShowList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                  colors: [Colors.white, Colors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
          ),
             Center(
               child: Column(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.red,
                      highlightColor: Colors.yellow,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 200.0),
                        child: Container(
                          child: Text('App Name',
                              style: TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic,
                                  fontFamily: 'Google')),
                        ),
                      ),
                    ),
                    Spacer(),
                    // SizedBox(height: 5.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30.0),
                      child: Center(
                        child: Text("Loading...",
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
             ),
        ],
      ),
    );
  }

  static Future loadItems() async {
    final dbhelper = Databasehelper.instance;
    try {
      var Items = new List<String>();
      String jsonString = await rootBundle.loadString('assets/groceries.json');
     // print(jsonString);

      var list = json.decode(jsonString);
      // print(list);

      for (int i = 0; i < list.length; i++) {
        Items.add(list[i]);
        Map<String, dynamic> row = {
          Databasehelper.Item: list[i],
        };
        dbhelper.insert(Databasehelper.Master,row);
        //print(list[i]);
      }
      setVisitingFlag(true);

    } catch (e) {
      print(e);
    }
  }
}

setVisitingFlag(bool value) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.setBool("alreadyVisited", value);
}

Future<bool> getVisitingFlag() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getBool("alreadyVisited");
}
