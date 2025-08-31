import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/models/user_model.dart';

class SchedulesScreen extends ConsumerStatefulWidget {
  const SchedulesScreen({super.key});

  @override
  ConsumerState<SchedulesScreen> createState() => _SchedulesScreenState();
}

class _SchedulesScreenState extends ConsumerState<SchedulesScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'week';
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _schedules = [
    {
      'id': '1',
      'title': 'درس حفظ القرآن الكريم',
      'description': 'حفظ سورة الفاتحة مع التجويد',
      'category': 'حفظ القرآن الكريم',
      'students': ['محمد أحمد علي', 'علي محمد أحمد'],
      'startTime': '09:00',
      'endTime': '10:30',
      'date': '2024-12-16',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'تأكد من إحضار المصحف والدفتر',
      'recurring': 'weekly',
    },
    {
      'id': '2',
      'title': 'درس التلاوة والتجويد',
      'description': 'تطبيق قواعد التجويد على سورة البقرة',
      'category': 'التلاوة والتجويد',
      'students': ['فاطمة أحمد علي', 'أمينة محمد علي'],
      'startTime': '11:00',
      'endTime': '12:30',
      'date': '2024-12-16',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'مراجعة القواعد الأساسية',
      'recurring': 'weekly',
    },
    {
      'id': '3',
      'title': 'درس اللغة العربية',
      'description': 'قواعد النحو الأساسية',
      'category': 'اللغة العربية',
      'students': ['محمد أحمد علي', 'فاطمة أحمد علي'],
      'startTime': '14:00',
      'endTime': '15:30',
      'date': '2024-12-16',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'حل التمارين في المنزل',
      'recurring': 'weekly',
    },
    {
      'id': '4',
      'title': 'درس حفظ القرآن الكريم',
      'description': 'حفظ سورة البقرة - الآيات 1-10',
      'category': 'حفظ القرآن الكريم',
      'students': ['علي محمد أحمد', 'أمينة محمد علي'],
      'startTime': '09:00',
      'endTime': '10:30',
      'date': '2024-12-17',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'مراجعة الحفظ السابق',
      'recurring': 'weekly',
    },
    {
      'id': '5',
      'title': 'درس التلاوة والتجويد',
      'description': 'تطبيق قواعد التجويد على سورة آل عمران',
      'category': 'التلاوة والتجويد',
      'students': ['محمد أحمد علي', 'فاطمة أحمد علي'],
      'startTime': '11:00',
      'endTime': '12:30',
      'date': '2024-12-17',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'تدريب على النطق الصحيح',
      'recurring': 'weekly',
    },
    {
      'id': '6',
      'title': 'درس حفظ القرآن الكريم',
      'description': 'حفظ سورة النساء - الآيات 1-5',
      'category': 'حفظ القرآن الكريم',
      'students': ['علي محمد أحمد', 'أمينة محمد علي'],
      'startTime': '09:00',
      'endTime': '10:30',
      'date': '2024-12-18',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'تقسيم الآيات للمذاكرة',
      'recurring': 'weekly',
    },
    {
      'id': '7',
      'title': 'درس اللغة العربية',
      'description': 'قواعد الإعراب الأساسية',
      'category': 'اللغة العربية',
      'students': ['محمد أحمد علي', 'فاطمة أحمد علي'],
      'startTime': '11:00',
      'endTime': '12:30',
      'date': '2024-12-18',
      'location': 'المسجد الرئيسي',
      'status': 'scheduled',
      'notes': 'تدريب عملي على الإعراب',
      'recurring': 'weekly',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredSchedules = _getFilteredSchedules();
    final weekSchedules = _getWeekSchedules();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الجدول الزمني',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة الدروس والمواعيد التعليمية',
                              style: AppTheme.arabicTextStyle.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // View Selector
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'عرض الجدول',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildViewButton('أسبوع', 'week', Icons.view_week),
                      const SizedBox(width: 12),
                      _buildViewButton('يوم', 'day', Icons.today),
                      const SizedBox(width: 12),
                      _buildViewButton('قائمة', 'list', Icons.list),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Date Navigation
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _previousDate(),
                    icon: const Icon(Icons.chevron_left),
                    color: AppTheme.primaryColor,
                  ),
                  Column(
                    children: [
                      Text(
                        _getDateLabel(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        _getFormattedDate(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => _nextDate(),
                    icon: const Icon(Icons.chevron_right),
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تصفية حسب الفئة',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'اختر الفئة',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      {'value': 'all', 'label': 'جميع الفئات'},
                      {'value': 'حفظ القرآن الكريم', 'label': 'حفظ القرآن الكريم'},
                      {'value': 'التلاوة والتجويد', 'label': 'التلاوة والتجويد'},
                      {'value': 'اللغة العربية', 'label': 'اللغة العربية'},
                    ].map((item) {
                      return DropdownMenuItem(
                        value: item['value'],
                        child: Text(item['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Actions
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _createNewSchedule(),
                      icon: const Icon(Icons.add),
                      label: const Text('موعد جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _bulkActions(),
                      icon: const Icon(Icons.more_vert),
                      label: const Text('إجراءات جماعية'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.secondaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Schedule Content
          if (_selectedView == 'week') ...[
            _buildWeekView(weekSchedules),
          ] else if (_selectedView == 'day') ...[
            _buildDayView(filteredSchedules),
          ] else ...[
            _buildListView(filteredSchedules),
          ],
        ],
      ),
    );
  }

  Widget _buildViewButton(String label, String value, IconData icon) {
    final isSelected = _selectedView == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedView = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekView(Map<String, List<Map<String, dynamic>>> weekSchedules) {
    final weekDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جدول الأسبوع',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...weekDays.map((day) {
              final daySchedules = weekSchedules[day] ?? [];
              return _buildDayColumn(day, daySchedules);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDayColumn(String day, List<Map<String, dynamic>> schedules) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  day,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${schedules.length} درس',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (schedules.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد دروس في هذا اليوم',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...schedules.map((schedule) => _buildScheduleCard(schedule)).toList(),
        ],
      ),
    );
  }

  Widget _buildDayView(List<Map<String, dynamic>> schedules) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'جدول اليوم',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (schedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد دروس في هذا اليوم',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...schedules.map((schedule) => _buildScheduleCard(schedule)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> schedules) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'قائمة المواعيد',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (schedules.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy,
                        color: Colors.grey[400],
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد مواعيد متاحة',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...schedules.map((schedule) => _buildScheduleCard(schedule)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getCategoryColor(schedule['category']).withOpacity(0.1),
                  _getCategoryColor(schedule['category']).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule['title'],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            schedule['description'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _buildStatusChip(schedule['status']),
                        const SizedBox(height: 8),
                        _buildRecurringChip(schedule['recurring']),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'الوقت',
                        '${schedule['startTime']} - ${schedule['endTime']}',
                        Icons.access_time,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'المكان',
                        schedule['location'],
                        Icons.location_on,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'الطلاب',
                        '${schedule['students'].length}',
                        Icons.people,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Students List
                Text(
                  'الطلاب المسجلون',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: schedule['students'].map<Widget>((student) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.infoColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        student,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.infoColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Notes
                if (schedule['notes'] != null && schedule['notes'].isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          color: AppTheme.warningColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            schedule['notes'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewScheduleDetails(schedule),
                        icon: const Icon(Icons.visibility),
                        label: const Text('عرض التفاصيل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editSchedule(schedule),
                        icon: const Icon(Icons.edit),
                        label: const Text('تعديل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteSchedule(schedule),
                        icon: const Icon(Icons.delete),
                        label: const Text('حذف'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusInfo['label'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecurringChip(String recurring) {
    final recurringInfo = _getRecurringInfo(recurring);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: recurringInfo['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        recurringInfo['label'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'scheduled':
        return {'label': 'مجدول', 'color': AppTheme.infoColor};
      case 'in_progress':
        return {'label': 'قيد التنفيذ', 'color': AppTheme.warningColor};
      case 'completed':
        return {'label': 'مكتمل', 'color': AppTheme.successColor};
      case 'cancelled':
        return {'label': 'ملغي', 'color': AppTheme.errorColor};
      default:
        return {'label': 'غير محدد', 'color': Colors.grey};
    }
  }

  Map<String, dynamic> _getRecurringInfo(String recurring) {
    switch (recurring) {
      case 'daily':
        return {'label': 'يومي', 'color': AppTheme.primaryColor};
      case 'weekly':
        return {'label': 'أسبوعي', 'color': AppTheme.infoColor};
      case 'monthly':
        return {'label': 'شهري', 'color': AppTheme.warningColor};
      case 'once':
        return {'label': 'مرة واحدة', 'color': AppTheme.secondaryColor};
      default:
        return {'label': 'غير محدد', 'color': Colors.grey};
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'حفظ القرآن الكريم':
        return AppTheme.primaryColor;
      case 'التلاوة والتجويد':
        return AppTheme.infoColor;
      case 'اللغة العربية':
        return AppTheme.secondaryColor;
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getFilteredSchedules() {
    return _schedules.where((schedule) {
      final categoryMatch = _selectedCategory == 'all' ||
          schedule['category'] == _selectedCategory;
      
      final dateMatch = schedule['date'] == _getFormattedDate();
      
      return categoryMatch && dateMatch;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> _getWeekSchedules() {
    final weekSchedules = <String, List<Map<String, dynamic>>>{};
    final weekDays = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    
    for (final day in weekDays) {
      weekSchedules[day] = [];
    }
    
    for (final schedule in _schedules) {
      final scheduleDate = DateTime.parse(schedule['date']);
      final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      if (scheduleDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          scheduleDate.isBefore(weekEnd.add(const Duration(days: 1))) ){
        final dayIndex = scheduleDate.weekday - 1;
        final dayName = weekDays[dayIndex];
        weekSchedules[dayName]!.add(schedule);
      }
    }
    
    return weekSchedules;
  }

  String _getDateLabel() {
    if (_selectedView == 'week') {
      final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      return 'الأسبوع ${weekStart.day} - ${weekEnd.day}';
    } else {
      return 'اليوم';
    }
  }

  String _getFormattedDate() {
    return '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  void _previousDate() {
    setState(() {
      if (_selectedView == 'week') {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      }
    });
  }

  void _nextDate() {
    setState(() {
      if (_selectedView == 'week') {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      }
    });
  }

  void _createNewSchedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 إنشاء موعد جديد - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _bulkActions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 الإجراءات الجماعية - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _viewScheduleDetails(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الموعد: ${schedule['title']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('العنوان', schedule['title']),
              _buildDetailRow('الوصف', schedule['description']),
              _buildDetailRow('الفئة', schedule['category']),
              _buildDetailRow('الطلاب', schedule['students'].join(', ')),
              _buildDetailRow('الوقت', '${schedule['startTime']} - ${schedule['endTime']}'),
              _buildDetailRow('التاريخ', schedule['date']),
              _buildDetailRow('المكان', schedule['location']),
              _buildDetailRow('الحالة', _getStatusInfo(schedule['status'])['label']),
              _buildDetailRow('التكرار', _getRecurringInfo(schedule['recurring'])['label']),
              if (schedule['notes'] != null && schedule['notes'].isNotEmpty)
                _buildDetailRow('ملاحظات', schedule['notes']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editSchedule(Map<String, dynamic> schedule) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 تعديل الموعد: ${schedule['title']} - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _deleteSchedule(Map<String, dynamic> schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموعد: ${schedule['title']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف الموعد: ${schedule['title']}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('حذف'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
