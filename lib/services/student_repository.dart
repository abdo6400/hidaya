import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import 'firebase_service.dart';

class StudentRepository {
  final CollectionReference _collection = FirebaseService.studentsRef;

  // Create student
  Future<String> createStudent(Student student) async {
    try {
      final docRef = await _collection.add(student.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create student: $e');
    }
  }

  // Get all students with calculated stats
  Stream<List<Student>> getAllStudentsWithStats() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final students = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Student.fromMap(data);
      }).toList();

      // Calculate stats for each student
      final studentsWithStats = <Student>[];
      for (final student in students) {
        final stats = await _calculateStudentStats(student.id);
        studentsWithStats.add(student.copyWith(
          totalGradedScore: stats['totalGradedScore'],
          attendanceCount: stats['attendanceCount'],
        ));
      }

      return studentsWithStats;
    });
  }

  // Calculate student stats from results
  Future<Map<String, dynamic>> _calculateStudentStats(String studentId) async {
    try {
      final resultsSnapshot = await FirebaseService.resultsRef
          .where('studentId', isEqualTo: studentId)
          .get();

      double totalGradedScore = 0.0;
      int attendanceCount = 0;

      for (var doc in resultsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final score = data['score'] as double?;
        final attendance = data['attendance'] as bool?;

        if (score != null) {
          totalGradedScore += score;
        }
        if (attendance == true) {
          attendanceCount++;
        }
      }

      return {
        'totalGradedScore': totalGradedScore,
        'attendanceCount': attendanceCount,
      };
    } catch (e) {
      return {
        'totalGradedScore': 0.0,
        'attendanceCount': 0,
      };
    }
  }

  // Get student by ID
  Future<Student?> getStudentById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Student.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get student: $e');
    }
  }

  // Update student
  Future<void> updateStudent(Student student) async {
    try {
      await _collection.doc(student.id).update(student.toMap());
    } catch (e) {
      throw Exception('Failed to update student: $e');
    }
  }

  // Delete student
  Future<void> deleteStudent(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete student: $e');
    }
  }

  // Get students by group
  Stream<List<Student>> getStudentsByGroup(String groupId) {
    return _collection
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Student.fromMap(data);
      }).toList();
    });
  }

  // Get students by sheikh
  Stream<List<Student>> getStudentsBySheikh(String sheikhId) {
    return _collection
        .where('sheikhId', isEqualTo: sheikhId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Student.fromMap(data);
      }).toList();
    });
  }

  // Update student score
  Future<void> updateStudentScore(String studentId, double score) async {
    try {
      await _collection.doc(studentId).update({
        'totalGradedScore': FieldValue.increment(score),
        'updatedAt': FirebaseService.currentTimestamp,
      });
    } catch (e) {
      throw Exception('Failed to update student score: $e');
    }
  }

  // Update student attendance count
  Future<void> updateStudentAttendance(String studentId, int count) async {
    try {
      await _collection.doc(studentId).update({
        'attendanceCount': FieldValue.increment(count),
        'updatedAt': FirebaseService.currentTimestamp,
      });
    } catch (e) {
      throw Exception('Failed to update student attendance: $e');
    }
  }
}
