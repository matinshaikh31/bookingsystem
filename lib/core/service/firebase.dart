import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FBAuth {
  static final auth = FirebaseAuth.instance;
}

class FBFireStore {
  static final fb = FirebaseFirestore.instance;
  static final users = fb.collection('users');
  static final tasks = fb.collection('tasks');
  static final settings = fb.collection('settings').doc('sets');
  static final customers = fb.collection('customers');
  static final trucks = fb.collection('trucks');
  static final logs = fb.collection('logs');

  // Helper method to get task logs subcollection
  static CollectionReference taskLogs(String taskId) {
    return tasks.doc(taskId).collection('logs');
  }
}
