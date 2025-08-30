import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> quickMarkAllPresent({
    required String categoryId,
    required String sheikhId,
    required DateTime date,
  }) async {
    final students = await _db
        .collection('children')
        .where('assignedCategories', arrayContains: categoryId)
        .get();

    final batch = _db.batch();
    for (final doc in students.docs) {
      final ref = _db.collection('attendance').doc();
      batch.set(ref, {
        'studentId': doc.id,
        'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
        'status': 'present',
        'sheikhId': sheikhId,
        'categoryId': categoryId,
      });
    }
    await batch.commit();
  }

  Future<List<Map<String, dynamic>>> getAttendanceOfStudent(String studentId) async {
    final q = await _db
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .orderBy('date', descending: true)
        .limit(30)
        .get();
    return q.docs.map((d) {
      final data = d.data();
      final ts = data['date'] as Timestamp?;
      final dt = ts?.toDate();
      return {
        'date': dt == null ? '-' : '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
        'status': (data['status'] as String?) ?? '-',
      };
    }).toList();
  }
}


