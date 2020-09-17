import 'dart:convert';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/models/item.model.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Todo - App",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var newTaskController = TextEditingController();

  void add() {
    if (newTaskController.text.isEmpty) {
      return;
    }

    var exists = widget.items
        .where((item) => item.title == newTaskController.text)
        .isNotEmpty;

    if (exists) {
      setState(() {
        _showExistingMessage();
      });
      print("ja existe");
      return;
    }

    setState(() {
      widget.items.add(Item(title: newTaskController.text, done: false));
      newTaskController.clear();

      save();
    });
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);

      save();
    });
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();

    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((item) => Item.fromJson(item)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  _HomePageState() {
    load();
  }

  Future save() async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: newTaskController,
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              labelText: "New Task",
              labelStyle: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.brown[600],
      ),
      body: widget.items.length > 0
          ? Container(
              color: Colors.yellow[50],
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (BuildContext context, int index) {
                  final item = widget.items[index];

                  return new Dismissible(
                    key: Key(item.title),
                    background: Container(
                      color: Colors.red,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: Text(item.title),
                      value: item.done,
                      activeColor: Colors.brown[600],
                      onChanged: (value) {
                        setState(() {
                          item.done = value;
                          save();
                        });
                      },
                    ),
                    onDismissed: (direction) {
                      remove(index);
                    },
                  );
                },
              ),
            )
          : new Container(
              child: Center(
                child: new Text("Tudo pronto, aproveite seu dia!",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown[600],
        child: Icon(Icons.add),
        onPressed: () {
          if (newTaskController.text.isEmpty) {
            _showEmptyTask();
          } else {
            add();
          }
        },
      ),
    );
  }

  void _showEmptyTask() {
    Flushbar(
      margin: EdgeInsets.all(15),
      borderRadius: 8,
      backgroundGradient: LinearGradient(
        colors: [Colors.yellow.shade700, Colors.yellow[600]],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(seconds: 3),
      title: 'Info',
      message: 'Digite um nome para a sua task!',
    )..show(context);
  }

  void _showExistingMessage() {
    Flushbar(
      margin: EdgeInsets.all(15),
      borderRadius: 8,
      backgroundGradient: LinearGradient(
        colors: [Colors.yellow.shade700, Colors.yellow[600]],
        stops: [0.6, 1],
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      duration: Duration(seconds: 3),
      title: 'Info',
      message: 'Mensagem já existente!',
    )..show(context);
  }
}
