import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'note.dart';
import 'task.dart';

class Detail extends StatefulWidget {
  final int myindex;

  const Detail({super.key, required this.myindex});

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  late Box<Note> mybox;
  late Note newNote;
  late TextEditingController _titleCotroller;
  late TextEditingController _tempTaskController;
  late TextEditingController _descController;
  var listOftask = <Task>[];
  @override
  void initState() {
    mybox = Hive.box("notesBox");
    _titleCotroller =
        TextEditingController(text: mybox.getAt(widget.myindex)!.title);
    _tempTaskController = TextEditingController();
    _descController =
        TextEditingController(text: mybox.getAt(widget.myindex)!.description);
    newNote = mybox.getAt(widget.myindex)!;
    listOftask = newNote.listOfTasks;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Modify note",
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  newNote.isFavour = !newNote.isFavour;
                });
              },
              icon: newNote.isFavour
                  ? Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                    )
                  : Icon(
                      CupertinoIcons.heart,
                      color: Colors.red,
                    ))
        ],
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.indigo,
            )),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) {
                      return AlertDialog(
                        title: Text(
                          "New Task",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TextField(
                            controller: _tempTaskController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(17),
                                label: Text("name"),
                                hintText: "Your task name",
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)))),
                          ),
                        ),
                        actions: [
                          MaterialButton(
                            minWidth: 100,
                            color: Colors.red,
                            height: 46,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18))),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          MaterialButton(
                            minWidth: 100,
                            color: Colors.indigoAccent,
                            height: 46,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18))),
                            onPressed: () {
                              var temp = Task(
                                  title: _tempTaskController.text,
                                  isChecked: false);
                              setState(() {
                                listOftask.add(temp);
                              });
                              _tempTaskController.clear();
                              Get.back();
                            },
                            child: Text(
                              "Create",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    });
              },
              padding: EdgeInsets.all(8),
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_outlined,
                    size: 25,
                    color: Colors.blue,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Add task",
                    style: TextStyle(color: Colors.blue, fontSize: 15),
                  )
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                newNote.description = _descController.text;
                newNote.title = _titleCotroller.text;
                newNote.listOfTasks = listOftask;
                newNote.date = DateTime.now();
                await newNote.save();
                Get.back();
              },
              padding: EdgeInsets.all(8),
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.save_outlined,
                    size: 25,
                    color: Colors.indigo,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Save note",
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title",
              style: TextStyle(color: Colors.grey),
            ),
            //   SizedBox(height: 10,),
            TextField(
              controller: _titleCotroller,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "List of task",
              style: TextStyle(color: Colors.grey),
            ),
            Visibility(
              visible: listOftask.length != 0,
              replacement: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "List of Task is empty",
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                ),
              ),
              child: Expanded(
                child: ListView.builder(
                  itemCount: listOftask.length,
                  itemBuilder: (ctx, index) => Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  listOftask[index].isChecked = !listOftask[index].isChecked;
                                });
                              },
                              icon: listOftask[index].isChecked ? Icon(
                                Icons.check_circle,
                                color: Colors.indigo,
                              ) : Icon(
                                Icons.check_circle_outline_outlined,
                                color: Colors.indigo,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              listOftask[index].title,
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                listOftask.removeAt(index);
                              });
                            },
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Text(
              "Description",
              style: TextStyle(color: Colors.grey),
            ),
            Expanded(
              child: TextField(
                controller: _descController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                expands: true,
                maxLines: null,
                maxLength: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
