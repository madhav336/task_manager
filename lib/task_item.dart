import 'package:hive/hive.dart';
part 'task_item.g.dart';

@HiveType(typeId:0)
class TaskItem extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  bool isDone=false;
  @HiveField(2)
  String ?desc;

  @HiveField(3)
  DateTime? dueDate;
  
  
  TaskItem({required this.name, this.isDone=false,this.desc='',this.dueDate});

  Map<String,dynamic> toMap(){
    return{
      'name':name,
      'desc':desc,
      'isDone':isDone,
      'dueDate':dueDate?.millisecondsSinceEpoch,
    };
  }
  factory TaskItem.fromMap(Map<String,dynamic>map){
    return TaskItem(
      name: map['name']??'No name',
      desc: map['desc']??'',
      isDone:map['isDone']??false,
      dueDate: map['dueDate']!=null?DateTime.fromMillisecondsSinceEpoch(map['dueDate']):null,
      );
  }
  void toggleDone(){
    isDone!=isDone;
  }
}