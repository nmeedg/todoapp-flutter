import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jiffy/jiffy.dart';
import 'package:todoapp/note.dart';

import 'detail.dart';
import 'task.dart';

class Like extends StatefulWidget {
  const Like({super.key});

  @override
  State<Like> createState() => _LikeState();
}

class _LikeState extends State<Like> {
  late Box<Note> mybox;
  late List<Note> likeNote;
  bool _isLoading = false;
  int countChecked(List<Task> tasks) {
    int count = 0;
    for (var element in tasks) {
      if (element.isChecked) {
        count++;
      }
    }

    return count;
  }

  void sortNote(Box<Note> pBox) {
    for (var note in pBox.values) {
      if (note.isFavour) {
        likeNote.add(note);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

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
    mybox = Hive.box("notesBox");
    likeNote = [];
    sortNote(mybox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favour note",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.indigo,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Visibility(
                visible: !_isLoading,
                replacement: const Center(
                  child: CircularProgressIndicator(),
                ),
                child: likeNote.isEmpty
                    ? const Center(child: Text("Your favorite list is empty"))
                    : ListView.separated(
                        itemBuilder: (ctx, index) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15))),
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                    () => Detail(
                                          myindex:
                                              getIndex(mybox, likeNote[index])!,
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
                                      likeNote[index].title,
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
                                                likeNote[index].date)
                                            .yMMMMEEEEdjm,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 13),
                                        child: Text(
                                          "${countChecked(likeNote[index].listOfTasks)}/${likeNote[index].listOfTasks.length}",
                                          style: const TextStyle(color: Colors.blue),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (ctx, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: likeNote.length,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
