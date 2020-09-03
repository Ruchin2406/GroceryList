import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery/screens/show_list.dart';
import 'package:grocery/utils/dbhelper.dart';
import '../theme/app_colors.dart';

class AddItem extends StatefulWidget {
  final int id;

  AddItem(this.id);

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  final dbhelper = Databasehelper.instance;
  List<String> Items = List<String>();
  bool validated = true;
  String errtext = "";
  TextEditingController externaladditemcontroller = TextEditingController();

  String currentText = "";
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    List<String> suggestions = List<String>();
    print(suggestions.length);
    suggestions.clear();
    return Scaffold(
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
      body: Column(
        children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
              child: FutureBuilder(
                future: dbhelper.queryall(Databasehelper.Master),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    snapshot.data.forEach((element) {
                      suggestions.add(element[Databasehelper.Item]);
                    });
                    return AutoCompleteTextField<String>(
                        decoration: new InputDecoration(
                          hintText: "Search Item",
                          hintStyle: TextStyle(
                              fontSize: 23.0,
                              fontFamily: "Google",
                              fontWeight: FontWeight.bold),
                          suffixIcon: IconButton(
                              onPressed: showAlertDialogue,
                              icon: Icon(
                                Icons.add_box,
                                color: AppColors.IconsColor,
                              )),
                        ),
                        key: key,
                        submitOnSuggestionTap: true,
                        clearOnSubmit: true,
                        suggestions: suggestions,
                        textInputAction: TextInputAction.go,
                        textChanged: (item) {
                          currentText = item;
                        },
                        itemSubmitted: (item) {
                          onItemSelected(item);
                        },
                        itemBuilder: (context, item) {
                          return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: new Text(item));
                        },
                        itemSorter: (a, b) {
                          return a.compareTo(b);
                        },
                        itemFilter: (item, query) {
                          return item
                              .toLowerCase()
                              .startsWith(query.toLowerCase());
                        });
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          Flexible(
            flex: 10,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder(
                  future: dbhelper.queryspecific(widget.id.toString()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                snapshot.data[index].row[1],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontFamily: "Google",
                                ),
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  dbhelper
                                      .deleteItem(snapshot.data[index].row[0]);
                                  setState(() {});
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: AppColors.IconsColor,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
          ),
          Spacer(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: RaisedButton(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  onPressed: () async {
                    List<Map<String, dynamic>> queryrows =
                        await dbhelper.queryall(Databasehelper.GroceryItem);
                    print(queryrows);
                    Navigator.pop(context);
                  },
                  color: AppColors.ButtonsBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  textColor: Colors.white,
                  child: Text(
                    "Save Grocery",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: "GOOGLE"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void onItemSelected(String item) async {
    Map<String, dynamic> row = {
      Databasehelper.ItemName: item,
      Databasehelper.ItemId: widget.id,
    };
    int id = await dbhelper.insert(Databasehelper.GroceryItem, row);
    print(id);
  }

  void externalAddItem(String item) async {
    Map<String, dynamic> row = {
      Databasehelper.Item: item,
    };
    int id = await dbhelper.insert(Databasehelper.Master, row);
    print(id);
    Navigator.pop(context);
    setState(() {
      validated = true;
      errtext = "";
    });
  }

  void showAlertDialogue() {
    externaladditemcontroller.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Text(
                "Add External Item",
                style: TextStyle(
                  fontSize: 23.0,
                  fontFamily: "Google",
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    controller: externaladditemcontroller,
                    autofocus: true,
                    onSubmitted: (text) {
                      Items.add(text);
                      externaladditemcontroller.clear();
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
                            if (externaladditemcontroller.text.isEmpty) {
                              setState(() {
                                errtext = "Can't Be Empty";
                                validated = false;
                              });
                            } else if (externaladditemcontroller.text.length >
                                12) {
                              setState(() {
                                errtext = "Too many Chanracters";
                                validated = false;
                              });
                            } else {
                              externalAddItem(externaladditemcontroller.text);
                            }
                          },
                          color: AppColors.ButtonsBackgroundColor,
                          child: Text("ADD",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: AppColors.ButtonsTextColor,
                                fontFamily: "Google",
                              )),
                        ),
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
