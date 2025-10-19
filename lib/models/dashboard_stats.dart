import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int studentCount;
  final int sheikhCount;
  final int taskCount;
  final double totalPoints;

  const DashboardStats({
    required this.studentCount,
    required this.sheikhCount,
    required this.taskCount,
    required this.totalPoints,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      studentCount: 0,
      sheikhCount: 0,
      taskCount: 0,
      totalPoints: 0.0,
    );
  }

  DashboardStats copyWith({
    int? studentCount,
    int? sheikhCount,
    int? taskCount,
    double? totalPoints,
  }) {
    return DashboardStats(
      studentCount: studentCount ?? this.studentCount,
      sheikhCount: sheikhCount ?? this.sheikhCount,
      taskCount: taskCount ?? this.taskCount,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }

  @override
  List<Object?> get props => [
        studentCount,
        sheikhCount,
        taskCount,
        totalPoints,
      ];
}
