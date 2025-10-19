import '../models/dashboard_stats.dart';
import 'firebase_service.dart';

class DashboardRepository {
  // Get dashboard statistics
  Future<DashboardStats> getDashboardStats() async {
    try {
      // Get counts from all collections
      final studentsSnapshot = await FirebaseService.studentsRef.get();
      final sheikhsSnapshot = await FirebaseService.sheikhsRef.get();
      final tasksSnapshot = await FirebaseService.tasksRef.get();
      
      // Calculate total points from results
      final resultsSnapshot = await FirebaseService.resultsRef
          .where('score', isNull: false)
          .get();
      
      double totalPoints = 0.0;
      for (var doc in resultsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final score = data['score'] as double?;
        if (score != null) {
          totalPoints += score;
        }
      }

      return DashboardStats(
        studentCount: studentsSnapshot.docs.length,
        sheikhCount: sheikhsSnapshot.docs.length,
        taskCount: tasksSnapshot.docs.length,
        totalPoints: totalPoints,
      );
    } catch (e) {
      throw Exception('Failed to get dashboard stats: $e');
    }
  }

  // Stream dashboard statistics
  Stream<DashboardStats> getDashboardStatsStream() {
    return Stream.periodic(const Duration(seconds: 30)).asyncMap((_) => getDashboardStats());
  }
}
