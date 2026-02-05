


import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_manager/sync_service.dart';
import 'package:task_manager/task_item.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final Box<TaskItem> taskBox=Hive.box<TaskItem>('tasks');
  @override
  void initState(){
    super.initState();
    SyncService.pullFromCloud(taskBox);
  }
  void logout()async {
    await taskBox.clear(); //so that the next user doesnt see prev user tasks
    await FirebaseAuth.instance.signOut(); //signout from firebase so that the next user gets his own collection
    if(mounted){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen())); //route to login screen
    }
  }
  void addTask(String newTaskTitle,newDesc){
    final newTask=TaskItem(name:newTaskTitle,desc: newDesc,dueDate: DateTime.now()); //create new task item
    taskBox.add(newTask); //add to local hive box
    newTask.save(); //save to hive box
    SyncService.syncTask(newTask);  //sync to firebase
    Navigator.pop(context); //close window
  }
  void showAddTaskDialog(){
    String newTaskTitle=' ';
    String newDesc='';
    showDialog(context: context, builder: (context){
      return AlertDialog( //popup box
        title:const Text('Add task'),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            TextField(
              autofocus:true,
              decoration: const InputDecoration(
                hintText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              
              onChanged: (newText){
                newTaskTitle=newText;
              },
              
            ),
            const SizedBox(height: 10,),
            TextField(
              autofocus:true,
              decoration: const InputDecoration(
                hintText: 'Description(Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              
              onChanged: (newText){
                newDesc=newText;
              },
              
            ),
          ],
        ),
        actions: [ //optional action buttons for a dialog box
          TextButton(
            onPressed:(){
              Navigator.pop(context);
            }, child: const Text('Cancel',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
            ),
          TextButton(
            onPressed: (){
              if(newTaskTitle.trim().isEmpty){
                ScaffoldMessenger.of(context).showSnackBar( //small bar at the bottom showing an error
                  const SnackBar(content: Text('Task name cannot be empty'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  ),

                );
                return;
              }
              addTask(newTaskTitle,newDesc); //add button
            },
            child: const Text('Add',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),),
            
          ),
          
        ],
      );
          });
  }
  void showEditTaskDialog(TaskItem task){
    String updatedTaskTitle=task.name;
    String updatedTaskDesc=task.desc??'';
      TextEditingController controller=TextEditingController(text:updatedTaskTitle); //controller for using the text that we enter
      TextEditingController controller2=TextEditingController(text:updatedTaskDesc); 
      showDialog(context: context, builder: (context){
        return AlertDialog(
          title:const Text('Edit Task'),
          content:Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder()
                ),
                autofocus: true,
                
                onChanged: (newText){
                  updatedTaskTitle=newText;  //set new title
                },
              ),
              const SizedBox(height: 15,),
              TextField(
                controller: controller2,
                maxLines: 5, //a bigger box for description
                minLines: 2,
                autofocus:true,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder()
                ),
                keyboardType: TextInputType.multiline,
                
                onChanged: (newText){
                  updatedTaskDesc=newText; //set new description
                },

              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
              style:  TextStyle(
                fontWeight: FontWeight.bold,
              ),),
            ),
            TextButton(onPressed: (){
              if(updatedTaskTitle.trim().isEmpty){ //for checking empty title
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Task name cannot be empty'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 3),
                  ),

                );
                return;
              }
              task.name=updatedTaskTitle;
              task.desc=updatedTaskDesc;
              task.save(); //save to hive
              SyncService.syncTask(task); //save to firebase
              Navigator.pop(context);
            }, 
            child: const Text('Save',
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            ),
            
          ],
        );
      });
  }
  Widget _buildTaskList({required List<TaskItem> currentTasks,required bool isCompletedTab}){ //build task list according to what tab it belongs to
    final filteredTasks=currentTasks.where((task)=>task.isDone==isCompletedTab).toList(); //completed tasks will be in completed tab and those are chosen or pending tasks in pending tab are chosen
    if(filteredTasks.isEmpty){
      return Center(
        child: Text(isCompletedTab?"No completed tasks yet":"No upcoming tasks",style: const TextStyle(color: Colors.grey),), //if tasks are empty then show appropriate text in centre
        
      );
    }
    return ListView.builder( //to show tasks as a list
          itemCount: filteredTasks.length,
          itemBuilder: (context,index){
            final task=filteredTasks[index];
            
            return Dismissible( //dismissible helps swipe to delete
              key: Key(task.name),
              background:  Container(
                decoration: BoxDecoration(
                  color:const Color(0xFFE57373), 
                  borderRadius: BorderRadius.circular(15)
                ),
                
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right:20),
                child: const Icon(Icons.delete,color: Colors.white,), //delete icon
              ),
              onDismissed: (direction) {
                final keyToDelete=task.key;
                task.delete();
                SyncService.deleteTask(keyToDelete); //delete on swipe
              },
              child: ListTile(
                title:Text(task.name,
                style: TextStyle(
                  decoration: task.isDone?TextDecoration.lineThrough:null, //strikethrough line
                  fontSize: 30,
                  
                ),
                textAlign: TextAlign.left,
                ),
                subtitle: Text(task.desc!),
                onTap:(){
                  showEditTaskDialog(task); //clicking on the task shows the dialog box
                } ,
                trailing: Checkbox(
                  shape: const CircleBorder(),
                  activeColor: Theme.of(context).colorScheme.secondary, //use the amber color for ticks defined in main.dart
                  checkColor: Colors.black,
                  value: task.isDone,
                  onChanged: (newValue) {
                    
                    task.isDone=newValue!; //toggle
                    task.save(); //save to hive
                    SyncService.syncTask(task); //sync to firebase 
                  },
                ),
              ),
            );
          },
        );
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(  //tab controller for tabs
      length: 2,
      child: Scaffold( 
        appBar: AppBar( 
          title: const Text('My Tasks',style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.lightGreenAccent,
          foregroundColor: Colors.white,
          centerTitle: true,
          bottom: const TabBar( //tab bar for the 2 tabs
            indicatorColor:Colors.white ,
            tabs: [
              Tab(text:'Upcoming'),
              Tab(text:'Completed')
            ],
          ),
          actions: [
            PopupMenuButton( //button for profile
              icon:CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(FirebaseAuth.instance.currentUser?.email?[0].toUpperCase()??"?", //get first char of email of logged in user
                style: const TextStyle(
                  fontWeight: FontWeight.bold,color:Colors.teal,
                ),
                ),
                
              ),
              onSelected: (value){
                if(value=='logout'){
                  logout();
                }
              },
              itemBuilder: (BuildContext context){
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Text(FirebaseAuth.instance.currentUser?.email??"Guest", //in the popup menu show 
                      style: const TextStyle(fontSize: 12,color: Colors.grey),
                    ),
                  ),
                    const PopupMenuItem(
                      value: 'logout', //this value is used to match the logout function
                      child: Row(
                        children: [
                          Icon(Icons.logout,color: Colors.black,), //logout icon
                          SizedBox(width: 10,),
                          Text('Log Out'), //log out text
                        ],
                      ),
                    ),
                ];
              }),
              const SizedBox(width: 10,)
          ],
        ),
        body: ValueListenableBuilder(valueListenable: taskBox.listenable(), // this helps to monitor a specific part of data and rebuild its part of the screen as soon as it changes
          builder: (context,Box<TaskItem>box, _){ 
            final allTasks=box.values.toList().cast<TaskItem>(); //convert the tasks into the type <TaskItem>
            return TabBarView(children: [ //tab bar for completed and upcoming
              _buildTaskList(currentTasks: allTasks, isCompletedTab: false),
              _buildTaskList(currentTasks: allTasks, isCompletedTab: true)
            ]);
          } ),
        floatingActionButton:  FloatingActionButton(onPressed: (){
          showAddTaskDialog();
          
        },
        tooltip: 'Add task', //shows up on long press
        child: const Icon(Icons.add),
        ),
      ),
    );
  }
}