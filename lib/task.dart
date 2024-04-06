import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 2)
class Task extends HiveObject {

  @HiveField(0)
  String title;
  
  @HiveField(1)
  bool isChecked;

  Task({required this.title, required this.isChecked});
}