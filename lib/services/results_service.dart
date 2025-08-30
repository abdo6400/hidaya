import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addResult({
    required String studentId,
    required String taskId,
    required DateTime date,
    required int points,
  }) async {
    await _db.collection('taskResults').add({
      'studentId': studentId,
      'taskId': taskId,
      'date': Timestamp.fromDate(date),
      'points': points,
    });
  }

  Future<List<Map<String, dynamic>>> getResultsOfStudent(String studentId) async {
    final q = await _db
        .collection('taskResults')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .limit(30)
        .get();
    return q.docs.map((d) {
      final data = d.data();
      final ts = data['date'] as Timestamp?;
      final dt = ts?.toDate();
      return {
        'taskId': data['taskId'],
        'taskTitle': data['taskTitle'],
        'points': data['points'],
        'date': dt == null ? '-' : '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
      };
    }).toList();
  }
}


