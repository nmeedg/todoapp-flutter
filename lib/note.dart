import 'package:hive/hive.dart';
import 'package:todoapp/task.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  bool isFavour;

  @HiveField(4)
  List<Task> listOfTasks=[];

  Note(this.title, this.description, this.date,[this.isFavour = false]);
}
