class AppConstants {
  // App Information
  static const String appTitle = 'هداية';
  static const String appSubtitle = 'منصة التعليم الإسلامي';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'تطبيق إدارة التعليم الإسلامي للمحفظين والطلاب وأولياء الأمور';
  
  // Navigation Labels
  static const String dashboard = 'الرئيسية';
  static const String sheikhs = 'المحفظين';
  static const String categories = 'الفئات';
  static const String tasks = 'المهام';
  static const String parents = 'أولياء الأمور';
  static const String students = 'الطلاب';
  static const String schedules = 'المواعيد';
  static const String reports = 'التقارير';
  static const String notifications = 'الإشعارات';
  static const String settings = 'الإعدادات';
  static const String profile = 'الملف الشخصي';
  
  // Common Actions
  static const String add = 'إضافة';
  static const String edit = 'تعديل';
  static const String delete = 'حذف';
  static const String save = 'حفظ';
  static const String cancel = 'إلغاء';
  static const String confirm = 'تأكيد';
  static const String close = 'إغلاق';
  static const String back = 'رجوع';
  static const String next = 'التالي';
  static const String previous = 'السابق';
  static const String search = 'بحث';
  static const String filter = 'تصفية';
  static const String refresh = 'تحديث';
  static const String loading = 'جاري التحميل...';
  static const String noData = 'لا توجد بيانات';
  static const String error = 'خطأ';
  static const String success = 'نجح';
  static const String warning = 'تحذير';
  static const String info = 'معلومات';
  
  // Status Labels
  static const String active = 'نشط';
  static const String inactive = 'غير نشط';
  static const String pending = 'في الانتظار';
  static const String completed = 'مكتمل';
  static const String cancelled = 'ملغي';
  static const String approved = 'موافق عليه';
  static const String rejected = 'مرفوض';
  
  // User Roles
  static const String adminRole = 'مدير';
  static const String sheikhRole = 'محفظ';
  static const String parentRole = 'ولي أمر';
  static const String studentRole = 'طالب';
  
  // Task Types
  static const String memorization = 'حفظ';
  static const String recitation = 'تلاوة';
  static const String behavior = 'سلوك';
  static const String attendance = 'حضور';
  static const String homework = 'واجب منزلي';
  static const String exam = 'امتحان';
  
  // Days of Week (Arabic)
  static const List<String> weekDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];
  
  // Time Slots
  static const List<String> timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
  ];
  
  // Grading Scales
  static const List<String> gradingScales = [
    '1-10',
    'أ/ب/ج/د',
    'ممتاز/جيد جداً/جيد/مقبول',
    'نعم/لا',
    'مكتمل/غير مكتمل',
  ];
  
  // Notification Types
  static const String announcement = 'إعلان';
  static const String taskResult = 'نتيجة مهمة';
  static const String attendanceUpdate = 'تحديث حضور';
  static const String scheduleChange = 'تغيير موعد';
  static const String general = 'عام';
  
  // Error Messages
  static const String networkError = 'خطأ في الاتصال بالشبكة';
  static const String serverError = 'خطأ في الخادم';
  static const String authError = 'خطأ في المصادقة';
  static const String validationError = 'خطأ في التحقق من صحة البيانات';
  static const String permissionError = 'ليس لديك صلاحية لتنفيذ هذا الإجراء';
  static const String unknownError = 'خطأ غير معروف';
  
  // Success Messages
  static const String dataSaved = 'تم حفظ البيانات بنجاح';
  static const String dataUpdated = 'تم تحديث البيانات بنجاح';
  static const String dataDeleted = 'تم حذف البيانات بنجاح';
  static const String operationCompleted = 'تم إكمال العملية بنجاح';
  
  // Validation Messages
  static const String requiredField = 'هذا الحقل مطلوب';
  static const String invalidEmail = 'البريد الإلكتروني غير صحيح';
  static const String invalidPhone = 'رقم الهاتف غير صحيح';
  static const String passwordTooShort = 'كلمة المرور قصيرة جداً';
  static const String passwordsDoNotMatch = 'كلمات المرور غير متطابقة';
  static const String usernameExists = 'اسم المستخدم موجود بالفعل';
  
  // App Features
  static const String featureAttendance = 'نظام الحضور والانصراف';
  static const String featureTasks = 'إدارة المهام والتقييم';
  static const String featureReports = 'التقارير والإحصائيات';
  static const String featureNotifications = 'نظام الإشعارات';
  static const String featureSchedules = 'إدارة المواعيد والجداول';
  static const String featureUsers = 'إدارة المستخدمين والصلاحيات';
}
