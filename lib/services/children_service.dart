import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/assignment_model.dart';

class ChildrenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _children => _firestore.collection('children');
  CollectionReference<Map<String, dynamic>> get _assignments => _firestore.collection('assignments');

  Future<List<ChildModel>> getAllChildren() async {
    final snapshot = await _children.get();
    return snapshot.docs.map((doc) => ChildModel.fromDoc(doc)).toList();
  }

  Future<void> assignChildToCategory(
    String childId,
    String categoryId,
    String sheikhId,
  ) async {
    // First, deactivate any existing active assignments for this child
    final existingAssignments = await _assignments
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();
    
    for (var doc in existingAssignments.docs) {
      await doc.reference.update({'isActive': false});
    }

    // Create new assignment
    final assignment = AssignmentModel(
      id: '', // Firestore will generate this
      childId: childId,
      categoryId: categoryId,
      sheikhId: sheikhId,
      assignedAt: DateTime.now(),
    );

    await _assignments.add(assignment.toMap());
  }

  Future<AssignmentModel?> getActiveAssignment(String childId) async {
    final snapshot = await _assignments
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return AssignmentModel.fromFirestore(snapshot.docs.first);
  }

  Future<void> unassignChildFromCategory(String childId) async {
    final existingAssignments = await _assignments
        .where('childId', isEqualTo: childId)
        .where('isActive', isEqualTo: true)
        .get();
    
    for (var doc in existingAssignments.docs) {
      await doc.reference.update({'isActive': false});
    }
  }

  Future<List<Map<String, dynamic>>> getChildrenAssignments() async {
    final snapshot = await _firestore.collection('children').get();
    return snapshot.docs
        .map((doc) => {
              ...doc.data(),
              'id': doc.id,
            })
        .toList();
  }
}
