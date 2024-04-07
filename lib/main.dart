import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todoapp/detail.dart';
import 'package:todoapp/like.dart';
import 'package:todoapp/task.dart';

import 'note.dart';

void main() async {
  await Hive.initFlutter();
  Hive
    ..registerAdapter(NoteAdapter())
    ..registerAdapter(TaskAdapter());

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
  late TextEditingController _textSearchController;
  late TextEditingController _tempTextController;
  late TextEditingController _tempDescController;
  List<Note> _myListSearched = [];
  void searchTextNote() {
    List<Note> temp = [];
    for (var i = 0; i < box.length; i++) {
      if (box
              .getAt(i)!
              .title
              .toLowerCase()
              .contains(_textSearchController.text.toLowerCase()) ||
          box
              .getAt(i)!
              .description
              .toLowerCase()
              .contains(_textSearchController.text.toLowerCase())) {
        temp.add(box.getAt(i)!);
      }
    }
    _myListSearched = temp;
  }

  int countChecked(List<Task> tasks) {
    int count = 0;
    for (var element in tasks) {
      if (element.isChecked) {
        count++;
      }
    }

    return count;
  }

  late Box<Note> box;

  int? getIndex(Box<Note> pBox, Note test) {
    for (var i = 0; i < pBox.length; i++) {
      if (pBox.getAt(i) == test) {
        return i;
      }
    }
    return null;
  }

  @override
  void initState() {
    _textSearchController = TextEditingController();
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => const Like());
              },
              icon: const Icon(
                CupertinoIcons.heart,
                color: Colors.indigo,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _textSearchController,
              onChanged: (temp) {
                searchTextNote();
                setState(() {});
              },
              decoration: InputDecoration(
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _textSearchController.text == ""
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () {
                            setState(() {
                              _textSearchController.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 20,
                          )),
                  hintText: "Enter the title or words of notes",
                  contentPadding: const EdgeInsets.all(15)),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: _textSearchController.text != ""
                  ? _myListSearched.isEmpty
                      ? const Center(
                          child: Text("Note not Found"),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (ctx2, index) => Dismissible(
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                bool? res = await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return AlertDialog.adaptive(
                                        title: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Trash",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(Icons.delete)
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                                "are you want to delete note :"),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Center(
                                              child: Text(
                                                _myListSearched[index].title,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back(result: false);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style:
                                                  TextStyle(color: Colors.indigo),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await _myListSearched[index].delete();
                                              Get.back(result: true);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                                return res ?? false;
                              } else {
                                Get.to(
                                    Detail(
                                      myindex: getIndex(box, _myListSearched[index])!,
                                    ),
                                    transition: Transition.zoom);
                              }
                              return false;
                            },
                            background: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.indigoAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Visibility(
                                      visible: _myListSearched[index].isFavour,
                                      replacement: const Icon(
                                        CupertinoIcons.heart,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.heart_fill,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Edit note",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            secondaryBackground: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Move to trash",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            key: Key(_myListSearched[index].key.toString()),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(15))),
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                      () => Detail(
                                            myindex: getIndex(box, _myListSearched[index])!,
                                          ),
                                      transition: Transition.fadeIn);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        _myListSearched[index].title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: const Icon(Icons.more_vert_rounded),
                                      contentPadding: const EdgeInsets.all(5),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Jiffy.parseFromDateTime(
                                                  _myListSearched[index].date)
                                              .yMMMMEEEEdjm,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 13),
                                          child: Text(
                                            "${countChecked(_myListSearched[index].listOfTasks)}/${_myListSearched[index].listOfTasks.length}",
                                            style:
                                                const TextStyle(color: Colors.blue),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          separatorBuilder: (ctx, index) => const SizedBox(
                            height: 10,
                          ),
                          itemCount: _myListSearched.length,
                        )
                  : ValueListenableBuilder(
                      valueListenable: box.listenable(),
                      builder: (ctx, mybox, _) {
                        if (mybox.length == 0) {
                          return const Center(
                            child: Text("List of notes is empty"),
                          );
                        }
                        return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (ctx2, index) => Dismissible(
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                bool? res = await showDialog(
                                    context: context,
                                    builder: (ctx) {
                                      return AlertDialog.adaptive(
                                        title: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Trash",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Icon(Icons.delete)
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                                "are you want to delete note :"),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Center(
                                              child: Text(
                                                mybox.getAt(index)!.title,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Get.back(result: false);
                                            },
                                            child: const Text(
                                              "Cancel",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              await mybox
                                                  .getAt(index)!
                                                  .delete();
                                              Get.back(result: true);
                                            },
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                  color: Colors.indigo),
                                            ),
                                          ),
                                        ],
                                      );
                                    });
                                return res ?? false;
                              } else {
                                Get.to(
                                    Detail(
                                      myindex: index,
                                    ),
                                    transition: Transition.zoom);
                              }
                              return false;
                            },
                            background: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.indigoAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Visibility(
                                      visible: mybox.getAt(index)!.isFavour,
                                      replacement: const Icon(
                                        CupertinoIcons.heart,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.heart_fill,
                                        color: Colors.red,
                                        size: 25,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Edit note",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            secondaryBackground: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: const Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "Move to trash",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            key: Key(mybox.getAt(index)!.key.toString()),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(15))),
                              child: InkWell(
                                onTap: () {
                                  Get.to(
                                      () => Detail(
                                            myindex: index,
                                          ),
                                      transition: Transition.fadeIn);
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        mybox.getAt(index)!.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: const Icon(Icons.more_vert_rounded),
                                      contentPadding: const EdgeInsets.all(5),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          Jiffy.parseFromDateTime(
                                                  mybox.getAt(index)!.date)
                                              .yMMMMEEEEdjm,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 13),
                                          child: Text(
                                            "${countChecked(mybox.getAt(index)!.listOfTasks)}/${mybox.getAt(index)!.listOfTasks.length}",
                                            style:
                                                const TextStyle(color: Colors.blue),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          separatorBuilder: (ctx, index) => const SizedBox(
                            height: 10,
                          ),
                          itemCount: mybox.length,
                        );
                      }),
            )
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
                  title: const Text(
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
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15))),
                            label: const Text("Name"),
                            hintText: "Enter the title",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  _tempTextController.clear();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 17,
                                )),
                            contentPadding: const EdgeInsets.all(15)),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _tempDescController,
                        maxLines: 3,
                        decoration: const InputDecoration(
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
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      onPressed: () {
                        _tempTextController.clear();
                        _tempDescController.clear();
                        Get.back();
                      },
                      child: const Text(
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              )
                            ),
                            content: Center(child: Text("Note can't have empty title",style: TextStyle(color: Colors.white),))));
                        }
                        _tempTextController.clear();
                        _tempDescController.clear();
                        Get.back();
                      },
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                      child: const Text(
                        "Validate",
                        style: TextStyle(color: Colors.white),
                      ),
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
