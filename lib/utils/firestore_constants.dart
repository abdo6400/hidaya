/// Firestore collection and document names
class FirestoreCollections {
  // Main collections
  static const String users = 'users';
  static const String categories = 'categories';
  static const String scheduleGroups = 'schedule_groups';
  static const String schedules = 'schedules';
  static const String children = 'children';
  static const String assignments = 'assignments';
  static const String attendance = 'attendance';
  static const String tasks = 'tasks';
  static const String childTasks = 'child_tasks';
  static const String results = 'taskResults';
  
  // Indexes
  static const String usernameIndex = 'usernameIndex';
}

/// Subcollections
class FirestoreSubcollections {
  static const String children = 'children';
  static const String assignments = 'assignments';
  static const String attendance = 'attendance';
  static const String tasks = 'tasks';
}

/// Field names
class FirestoreFields {
  // Common fields
  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String status = 'status';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  
  // User fields
  static const String username = 'username';
  static const String password = 'password';
  static const String role = 'role';
  static const String phone = 'phone';
  static const String email = 'email';
  
  // Child fields
  static const String childId = 'childId';
  static const String parentId = 'parentId';
  static const String birthDate = 'birthDate';
  static const String gender = 'gender';
  static const String notes = 'notes';
  
  // Assignment fields
  static const String studentId = 'studentId';
  static const String taskId = 'taskId';
  static const String categoryId = 'categoryId';
  static const String groupId = 'groupId';
  static const String sheikhId = 'sheikhId';
  static const String assignedAt = 'assignedAt';
  static const String assignedBy = 'assignedBy';
  static const String completedAt = 'completedAt';
  static const String mark = 'mark';
  
  // Attendance fields
  static const String date = 'date';
  static const String attendanceStatus = 'status';
  
  // Schedule group fields
  static const String weekDays = 'weekDays';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String isActive = 'isActive';
  
  // Task fields
  static const String title = 'title';
  static const String dueDate = 'dueDate';
  static const String priority = 'priority';
  static const String points = 'points';
  static const String assignedCategories = 'assignedCategories';
  
  // Results fields
  static const String resultId = 'resultId';
  
  // Child task fields
  static const String childTaskId = 'childTaskId';
}
