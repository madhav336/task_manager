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
        await userTasksRef!.doc(task.key.toString()).set(task.toMap());
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
      await userTasksRef!.doc(taskKey.toString()).delete();
    }
  }
  static Future<void>pullFromCloud(Box<TaskItem>box)async{
    if(await canSync()){
      try{
      final snapshot=await userTasksRef!.get();
      final cloudKeys=<int>{};
      for(var doc in snapshot.docs){
        final data=doc.data() as Map<String,dynamic>;
        final task=TaskItem.fromMap(data);
        final key=int.tryParse(doc.id);
        if(key!=null){
          await box.put(key,task);
          cloudKeys.add(key);
        }
        
      }
      final localKeys=box.keys.cast<int>().toSet();
      final keysToDelete=localKeys.difference(cloudKeys);
      for(var key in keysToDelete){
        await box.delete(key);
      }
    }
    catch(e){
      print('$e');
    }
    }
    
    
  }
}