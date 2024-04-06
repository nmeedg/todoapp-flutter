import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todoapp/like.dart';

import 'note.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(NoteAdapter());
  await Hive.openBox<Note>("notesBox");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Todo app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textController;
  late TextEditingController _tempTextController;
  late TextEditingController _tempDescController;
  void submitText() {
    debugPrint(_textController.text);
  }

  late Box<Note> box;

  @override
  void initState() {
    _textController = TextEditingController();
    _tempDescController = TextEditingController();
    _tempTextController = TextEditingController();
    box = Hive.box("notesBox");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(()=> Like());
              },
              icon: Icon(
                CupertinoIcons.heart_fill,
                color: Colors.red,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  suffixIcon: Icon(Icons.search),
                  hintText: "Enter the title or words of notes",
                  contentPadding: EdgeInsets.all(15)),
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (ctx, mybox, _) {
                      if (mybox.length == 0) {
                        return Center(
                          child: Text("List of notes is empty"),
                        );
                      }
                      return ListView.separated(
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (ctx2, index) => Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15))),
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    mybox.getAt(index)!.title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(Icons.more_vert_rounded),
                                  contentPadding: EdgeInsets.all(5),
                                ),
                                Text(
                                  mybox.getAt(index)!.date.toIso8601String(),
                                  style: TextStyle(color: Colors.grey),
                                )
                              ],
                            ),
                          ),
                        ),
                        separatorBuilder: (ctx, index) => SizedBox(
                          height: 10,
                        ),
                        itemCount: mybox.length,
                      );
                    }))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  actionsAlignment: MainAxisAlignment.spaceBetween,
                  title: Text(
                    "Create note",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (textValue) {
                          setState(() {});
                        },
                        controller: _tempTextController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            label: Text("Name"),
                            hintText: "Enter the title",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _tempTextController.clear();
                                },
                                icon: Icon(
                                  Icons.close,
                                  size: 17,
                                )),
                            contentPadding: EdgeInsets.all(15)),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _tempDescController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            label: Text("Description"),
                            hintText: "Enter the description of note",
                            contentPadding: EdgeInsets.all(15)),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                  actions: [
                    MaterialButton(
                      minWidth: 100,
                      color: Colors.red,
                      height: 47,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      onPressed: () {
                        _tempTextController.clear();
                        _tempDescController.clear();
                        Get.back();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    MaterialButton(
                      minWidth: 100,
                      color: Colors.indigo,
                      height: 47,
                      onPressed: () {
                        if (_tempTextController.text != "") {
                          box.add(Note(
                            _tempTextController.text,
                            _tempDescController.text,
                            DateTime.now(),
                          ));
                        } else {
                          print("Note mot vide");
                        }
                        _tempTextController.clear();
                        _tempDescController.clear();
                        Get.back();
                      },
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Colors.white),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                    ),
                  ],
                  //        icon: Icon(Icons.new_label),
                );
              });
        },
        tooltip: 'New note',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
