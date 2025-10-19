# نظام متابعة حفظ القرآن - Qur'an Memorization Management System

A comprehensive Flutter mobile application for managing Qur'an memorization students, sheikhs, groups, and tasks with Firebase backend and BLoC state management.

## Features

### 🏠 Dashboard
- Summary cards showing total students, sheikhs, tasks, and points
- Quick action buttons for common operations
- Real-time statistics updates

### 👨‍🎓 Students Management
- Add, edit, and delete students
- Track student progress and attendance
- Assign students to groups and sheikhs
- View detailed student information

### 🕌 Sheikhs Management
- Manage sheikh information
- Track assigned students
- Group management

### 👥 Groups Management
- Create and manage student groups
- Assign sheikhs to groups
- Add/remove students from groups

### ✅ Tasks Management
- Two types of tasks: Graded (درجات) and Attendance (حضور)
- Create tasks with maximum scores for graded tasks
- Track task completion and results

### 📊 Reports
- Student ranking by total points
- Attendance tracking
- Date range filtering
- Comprehensive reporting system

## Technical Stack

- **Frontend**: Flutter 3.9.0+
- **State Management**: BLoC (flutter_bloc)
- **Backend**: Firebase (Firestore, Auth)
- **Navigation**: GoRouter
- **UI**: Material Design 3 with RTL support
- **Language**: Arabic (RTL layout)

## Project Structure

```
lib/
├── bloc/                    # BLoC state management
│   ├── dashboard/          # Dashboard BLoC
│   ├── students/           # Students BLoC
│   ├── tasks/              # Tasks BLOC
│   └── results/            # Results BLoC
├── constants/              # App constants
│   ├── app_colors.dart     # Color scheme
│   ├── app_strings.dart    # Arabic strings
│   └── app_theme.dart      # Theme configuration
├── models/                 # Data models
│   ├── student.dart        # Student model
│   ├── sheikh.dart         # Sheikh model
│   ├── group.dart          # Group model
│   ├── task.dart           # Task model
│   ├── result.dart         # Result model
│   └── dashboard_stats.dart # Dashboard statistics
├── screens/                # UI screens
│   ├── dashboard/          # Dashboard screen
│   ├── students/           # Students screens
│   ├── sheikhs/            # Sheikhs screens
│   ├── groups/             # Groups screens
│   ├── tasks/              # Tasks screens
│   └── reports/            # Reports screens
├── services/               # Firebase services
│   ├── firebase_service.dart    # Firebase configuration
│   ├── student_repository.dart  # Student data operations
│   ├── sheikh_repository.dart   # Sheikh data operations
│   ├── group_repository.dart    # Group data operations
│   ├── task_repository.dart     # Task data operations
│   ├── result_repository.dart   # Result data operations
│   └── dashboard_repository.dart # Dashboard statistics
├── widgets/                # Reusable widgets
│   └── dashboard/          # Dashboard widgets
└── main.dart              # App entry point
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.9.0 or higher
- Dart SDK 3.0.0 or higher
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd hidaya
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Firestore and Authentication
   - Download `google-services.json` for Android
   - Download `GoogleService-Info.plist` for iOS
   - Place them in the appropriate directories

4. **Arabic Fonts Setup**
   - Download Cairo font family from Google Fonts
   - Place the font files in `assets/fonts/` directory:
     - Cairo-Regular.ttf
     - Cairo-Bold.ttf
     - Cairo-SemiBold.ttf
     - Cairo-Medium.ttf

5. **Run the application**
   ```bash
   flutter run
   ```

## Firebase Configuration

### Firestore Collections
- `students` - Student information
- `sheikhs` - Sheikh information
- `groups` - Group information
- `tasks` - Task definitions
- `results` - Task results and attendance

### Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write access to all documents for authenticated users
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Features Implementation Status

### ✅ Completed
- [x] Project structure setup
- [x] Firebase integration
- [x] BLoC state management
- [x] Data models
- [x] Repository pattern
- [x] RTL support and Arabic theme
- [x] Dashboard with summary cards
- [x] Basic navigation structure
- [x] Students management (basic)

### 🚧 In Progress
- [ ] Complete students management forms
- [ ] Sheikhs management screens
- [ ] Groups management screens
- [ ] Tasks management screens
- [ ] Reports screens
- [ ] Form validation
- [ ] Search and filtering

### 📋 Planned
- [ ] User authentication
- [ ] Data export/import
- [ ] Offline support
- [ ] Push notifications
- [ ] Advanced reporting
- [ ] Settings and preferences

## Color Scheme

- **Primary**: #1ABC9C (Green)
- **Accent**: #F1C40F (Gold)
- **Background**: #F8F9FA (Light Gray)
- **Surface**: #FFFFFF (White)
- **Text Primary**: #2C3E50 (Dark Blue)
- **Text Secondary**: #7F8C8D (Gray)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**نظام متابعة حفظ القرآن** - تطبيق شامل لإدارة طلاب القرآن الكريم