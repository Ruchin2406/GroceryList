import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/screens/add_item.dart';
import 'package:grocery/screens/pdf_preview.dart';
import 'package:grocery/theme/app_colors.dart';
import 'package:grocery/utils/dbhelper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ShowList extends StatefulWidget {
  @override
  _ShowListState createState() => _ShowListState();
}

class _ShowListState extends State<ShowList> {
  final dbhelper = Databasehelper.instance;
  final titleTextController = TextEditingController();
  List<String> Items = List<String>();
  bool validated = true;
  String errtext = "";

  final pdf = pw.Document();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: showAlertDialogue,
        child: Icon(
          Icons.add,
          size: 30,
        ),
        backgroundColor: AppColors.ButtonsBackgroundColor,
      ),
      appBar: AppBar(
        title: Text(
          "App Name",
          style: TextStyle(
              fontSize: 23.0,
              fontFamily: "Google",
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.AppbarColor,
      ),
      body: FutureBuilder<List>(
        future: dbhelper.queryall(Databasehelper.GroceryList),
        initialData: List(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return ListView.builder(
            padding: EdgeInsets.only(top: 10.0),
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return Card(
                elevation: 5.0,
                color: AppColors.ListCardColors,
                shadowColor: Colors.black,
                margin: EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 12.0,
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                  child: ListTile(
                    title: Text(
                      snapshot.data[index].row[1],
                      style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Google",
                      ),
                    ),
                    trailing: Column(
                      children: [
                        GestureDetector(
                            onTap: () {},
                            child: Icon(
                              Icons.save,
                              color: AppColors.IconsColor,
                            )),
                        Spacer(),
                        GestureDetector(
                            onTap: () async {
                              Directory documentDirectory =
                                  await getApplicationDocumentsDirectory();

                              String documentPath = documentDirectory.path;

                              String fullPath = "$documentPath/grocery.pdf";

                              String response = "";
                              Databasehelper.instance
                                  .queryspecific(
                                      snapshot.data[index].row[0].toString())
                                  .then((value) {
                                value.forEach((element) {
                                  response = response +
                                      element[Databasehelper.ItemName] +
                                      '\n' +
                                      '\n';
                                });
                                print(response);
                                writeOnPdf(response);
                                savePdf();

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PdfPreviewScreen(
                                              path: fullPath,
                                            )));
                              });
                            },
                            child: Icon(
                              Icons.share,
                              color: AppColors.IconsColor,
                            )),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (BuildContext context) =>
                                  AddItem(snapshot.data[index].row[0])));
                    },
                    onLongPress: () {
                      dbhelper.deleteList(snapshot.data[index].row[0]);
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  writeOnPdf(String response) async {
    print("Hello");
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
                level: 0,
                child: pw.Row(children: [
                  pw.Text('Groceries List', textScaleFactor: 3),
                ])),
            pw.Header(
                level: 1,
                child: pw.Column(
                  children: [
                    pw.Text(response, textScaleFactor: 2),
                  ],
                )),
          ];
        },
      ),
    );
  }

  Future savePdf() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    String documentPath = documentDirectory.path;

    File file = File("$documentPath/grocery.pdf");

    file.writeAsBytesSync(pdf.save());
  }

  void onSubmitList(String title) async {
    Map<String, dynamic> row = {
      Databasehelper.ListName: title,
    };
    int id = await dbhelper.insert(Databasehelper.GroceryList, row);
    print(id);
    Navigator.pop(context);
    setState(() {
      validated = true;
      errtext = "";
    });
  }

  loadItem() async {
    List<String> Items = List<String>();
    dbhelper.queryall(Databasehelper.Master);
    build(context, snapshot) {
      if (snapshot.hasData) {
        snapshot.data.forEach((element) {
          Items.add(element[Databasehelper.Item]);
        });
        return Container(
          child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    snapshot.data[index].row[1],
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Raleway",
                    ),
                  ),
                );
              }),
        );
      } else {
        return Container();
      }
    }
  }

  void showAlertDialogue() {
    titleTextController.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                "Add List",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: "Google",
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: titleTextController,
                    autofocus: true,
                    onSubmitted: (text) {
                      Items.add(text);
                      titleTextController.clear();
                      setState(() {});
                    },
                    style: TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Google",
                    ),
                    decoration: InputDecoration(
                      errorText: validated ? null : errtext,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () {
                            if (titleTextController.text.isEmpty) {
                              setState(() {
                                errtext = "Can't Be Empty";
                                validated = false;
                              });
                            } else if (titleTextController.text.length > 12) {
                              setState(() {
                                errtext = "Too may Chanracters";
                                validated = false;
                              });
                            } else {
                              onSubmitList(titleTextController.text);
                            }
                          },
                          color: AppColors.ButtonsBackgroundColor,
                          child: Text("ADD",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: AppColors.ButtonsTextColor,
                                fontFamily: "Google",
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          });
        });
  }
}
