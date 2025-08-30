import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/reports_service.dart';

final reportsServiceProvider = Provider((ref) => ReportsService());

final overallStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.read(reportsServiceProvider);
  return await service.getOverallStatistics();
});

final groupPerformanceProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.read(reportsServiceProvider);
  return await service.getGroupPerformance();
});

final childPerformanceProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.read(reportsServiceProvider);
  return await service.getChildPerformance();
});

final sheikhPerformanceProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.read(reportsServiceProvider);
  return await service.getSheikhPerformance();
});

final recentActivityProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final service = ref.read(reportsServiceProvider);
  return await service.getRecentActivity();
});

final monthlyStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.read(reportsServiceProvider);
  return await service.getMonthlyStatistics();
});

class ReportsController
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ReportsService _service;

  ReportsController(this._service) : super(const AsyncValue.loading()) {
    loadOverallStatistics();
  }

  Future<void> loadOverallStatistics() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getOverallStatistics());
  }

  Future<void> refreshAllReports() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getOverallStatistics());
  }
}

final reportsControllerProvider =
    StateNotifierProvider<ReportsController, AsyncValue<Map<String, dynamic>>>((
      ref,
    ) {
      final service = ref.read(reportsServiceProvider);
      return ReportsController(service);
    });
