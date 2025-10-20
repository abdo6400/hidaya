import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String studentsCollection = 'students';
  static const String sheikhsCollection = 'sheikhs';
  static const String tasksCollection = 'tasks';
  static const String resultsCollection = 'results';

  // Auth
  static FirebaseAuth get auth => _auth;
  static User? get currentUser => _auth.currentUser;

  // Firestore
  static FirebaseFirestore get firestore => _firestore;

  // Collection references
  static CollectionReference get studentsRef => _firestore.collection(studentsCollection);
  static CollectionReference get sheikhsRef => _firestore.collection(sheikhsCollection);
  static CollectionReference get tasksRef => _firestore.collection(tasksCollection);
  static CollectionReference get resultsRef => _firestore.collection(resultsCollection);

  // Helper methods
  static String generateId() {
    return _firestore.collection('temp').doc().id;
  }

  static Timestamp get currentTimestamp => Timestamp.now();

  // Batch operations
  static WriteBatch batch() => _firestore.batch();
}
