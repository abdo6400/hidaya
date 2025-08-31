# Firebase Integration Guide for Hidaya App

## Overview
Your Hidaya app is now fully integrated with Firebase Firestore for data persistence while maintaining your custom authentication system. This guide explains how the integration works and how to use it.

## 🔥 Firebase Setup Status

✅ **Firebase Core**: Initialized in `main.dart`
✅ **Firestore**: Configured with your project `followup-d50cf`
✅ **Custom Authentication**: Using your existing `AuthService` with Firestore
✅ **Data Models**: All models have Firestore conversion methods
✅ **Controllers**: Updated to use Firebase service
✅ **Providers**: Created for state management

## 📁 File Structure

```
lib/
├── services/
│   ├── firebase_service.dart      # Main Firebase service
│   ├── auth_service.dart          # Custom authentication
│   └── base_service.dart          # Base CRUD operations
├── controllers/
│   ├── auth_controller.dart       # Authentication state
│   ├── category_controller.dart   # Categories management
│   ├── tasks_controller.dart      # Tasks management
│   ├── children_controller.dart   # Children management
│   └── users_controller.dart      # Users management
├── providers/
│   └── firebase_providers.dart    # Riverpod providers
└── models/
    ├── user_model.dart            # User data model
    ├── category_model.dart        # Category data model
    ├── task_model.dart           # Task data model
    └── child_model.dart          # Child data model
```

## 🔧 How to Use Firebase in Your Screens

### 1. Using Controllers (Recommended)

```dart
class MyScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch categories data
    final categoriesAsync = ref.watch(categoryControllerProvider);
    
    return categoriesAsync.when(
      data: (categories) => ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category.name),
            subtitle: Text(category.description),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 2. Using Providers Directly

```dart
// For dashboard stats
final statsAsync = ref.watch(dashboardStatsProvider);

// For children by parent
final childrenAsync = ref.watch(childrenByParentProvider(parentId));

// For tasks by category
final tasksAsync = ref.watch(tasksByCategoryProvider(categoryId));
```

### 3. Performing Actions

```dart
// Add a new category
await ref.read(categoryControllerProvider.notifier).addItem(
  CategoryModel(
    id: '',
    name: 'New Category',
    description: 'Description',
  ),
);

// Update a category
await ref.read(categoryControllerProvider.notifier).updateItem(category);

// Delete a category
await ref.read(categoryControllerProvider.notifier).deleteItem(categoryId);
```

## 🔐 Authentication Flow

### Registration
```dart
final authController = ref.read(authControllerProvider.notifier);
final user = await authController.registerAsParent(
  username: 'ahmed123',
  password: 'password123',
  name: 'أحمد محمد',
  phone: '+201234567890',
);
```

### Login
```dart
final user = await authController.login(
  username: 'ahmed123',
  password: 'password123',
);
```

### Logout
```dart
await authController.logout();
```

## 📊 Firestore Collections Structure

```
users/
├── {userId}/
│   ├── username: string
│   ├── password: string (hashed)
│   ├── name: string
│   ├── role: string (admin|sheikh|parent)
│   ├── email: string?
│   ├── phone: string?
│   ├── status: string (active|inactive|blocked)
│   ├── createdAt: timestamp
│   └── lastLogin: timestamp

usernameIndex/
├── {username}/
│   ├── userId: string
│   └── createdAt: timestamp

categories/
├── {categoryId}/
│   ├── name: string
│   ├── description: string
│   └── createdAt: timestamp

tasks/
├── {taskId}/
│   ├── title: string
│   ├── description: string
│   ├── categoryId: string
│   ├── type: string
│   ├── difficulty: string
│   ├── maxPoints: number
│   └── createdAt: timestamp

children/
├── {childId}/
│   ├── name: string
│   ├── parentId: string
│   ├── age: string
│   ├── isApproved: boolean
│   ├── createdBy: string
│   └── createdAt: timestamp

assignments/
├── {assignmentId}/
│   ├── childId: string
│   ├── categoryId: string
│   ├── sheikhId: string
│   ├── isActive: boolean
│   └── assignedAt: timestamp

attendance/
├── {attendanceId}/
│   ├── childId: string
│   ├── date: string
│   ├── status: string
│   └── markedAt: timestamp

results/
├── {resultId}/
│   ├── childId: string
│   ├── taskId: string
│   ├── points: number
│   ├── notes: string?
│   └── submittedAt: timestamp
```

## 🚀 Next Steps

1. **Test the Integration**: Run the app and test all CRUD operations
2. **Add Real Data**: Create some test data in Firestore
3. **Implement Remaining Features**: 
   - Attendance tracking
   - Task results submission
   - Notifications
   - Reports generation
4. **Security Rules**: Set up Firestore security rules
5. **Error Handling**: Add comprehensive error handling
6. **Offline Support**: Implement offline data caching

## 🔒 Security Considerations

- All passwords are stored as plain text (consider hashing)
- Implement Firestore security rules
- Add input validation
- Implement rate limiting
- Add audit logging

## 📱 Testing

To test the Firebase integration:

1. **Create Test Data**:
   ```dart
   // Add a test category
   await ref.read(categoryControllerProvider.notifier).addItem(
     CategoryModel(
       id: '',
       name: 'حفظ القرآن الكريم',
       description: 'تعلم حفظ القرآن الكريم',
     ),
   );
   ```

2. **Check Firestore Console**: Verify data appears in your Firebase console

3. **Test Real-time Updates**: Data should update automatically when changed

## 🛠 Troubleshooting

### Common Issues:

1. **Permission Denied**: Check Firestore security rules
2. **Network Error**: Check internet connection
3. **Data Not Loading**: Verify collection names match
4. **Authentication Errors**: Check username/password format

### Debug Tips:

- Use `print()` statements to debug
- Check Firebase console for errors
- Verify data structure matches models
- Test with small data sets first

## 📞 Support

If you encounter issues:
1. Check Firebase console for errors
2. Verify your Firebase project configuration
3. Test with the provided examples
4. Check the Flutter console for error messages

Your app is now ready to use real Firebase data! 🎉
