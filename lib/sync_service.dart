import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_item.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SyncService {
  static CollectionReference? get userTasksRef{
    final user=FirebaseAuth.instance.currentUser; //get the user
    if(user==null){
      return null;  //no collection ref if no user logged in
    } 
    return FirebaseFirestore.instance.collection('users').doc(user.uid).collection('tasks'); //get the tasks from firebase
  }
  static Future<bool> canSync() async{
    var connectivityResult=await(Connectivity().checkConnectivity()); //check connectivity using connectivity_plus library
    bool hasInternet=(connectivityResult.contains(ConnectivityResult.mobile)||connectivityResult.contains(ConnectivityResult.wifi)||connectivityResult.contains(ConnectivityResult.ethernet)); //it returns a List so find the desired values
    bool isLoggedIn=FirebaseAuth.instance.currentUser!=null; 
    return hasInternet&&isLoggedIn; 
  }
  static Future<void> syncTask(TaskItem task)async{
    if(await canSync()){
      try{
        await userTasksRef!.doc(task.key.toString()).set(task.toMap()); //sync task to firebase
      }
      catch(e){
        //
      }
    }
    else{
      //hive only
    }
  }
  static Future<void>deleteTask(dynamic taskKey)async{
    if(await canSync()){
      await userTasksRef!.doc(taskKey.toString()).delete(); //delete from firebase
    }
  }
  static Future<void>pullFromCloud(Box<TaskItem>box)async{
    if(await canSync()){
      try{
      final snapshot=await userTasksRef!.get(); //get task snapshot
      final cloudKeys=<int>{}; //create empty set of keys present in cloud
      for(var doc in snapshot.docs){ //for each task in tasks
        final data=doc.data() as Map<String,dynamic>; //get data as a json
        final task=TaskItem.fromMap(data); //create task from json data
        final key=int.tryParse(doc.id); //get key as an integer
        if(key!=null){ 
          await box.put(key,task); //add to hive
          cloudKeys.add(key); //add to safe list
        }
        
      }
      final localKeys=box.keys.cast<int>().toSet(); //find keys of hive
      final keysToDelete=localKeys.difference(cloudKeys); //keys which are in hive but not in database
      for(var key in keysToDelete){
        await box.delete(key); //delete
      }
    }
    catch(e){
      print('$e');
    }
    }
    
    
  }
}