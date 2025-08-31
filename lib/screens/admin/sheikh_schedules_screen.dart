import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/constants.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:quickalert/quickalert.dart';

class SheikhSchedulesScreen extends ConsumerStatefulWidget {
  const SheikhSchedulesScreen({super.key});

  @override
  ConsumerState<SheikhSchedulesScreen> createState() => _SheikhSchedulesScreenState();
}

class _SheikhSchedulesScreenState extends ConsumerState<SheikhSchedulesScreen> {
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': '1',
      'sheikhName': 'الشيخ أحمد محمد',
      'category': 'حفظ القرآن الكريم',
      'day': 'الأحد',
      'startTime': '09:00',
      'endTime': '11:00',
      'maxStudents': 15,
      'currentStudents': 12,
      'location': 'المسجد الكبير - الطابق الأول',
      'isActive': true,
      'createdAt': '2024-01-15',
    },
    {
      'id': '2',
      'sheikhName': 'الشيخ محمد علي',
      'category': 'التلاوة والتجويد',
      'day': 'الاثنين',
      'startTime': '14:00',
      'endTime': '16:00',
      'maxStudents': 12,
      'currentStudents': 8,
      'location': 'المسجد الكبير - الطابق الثاني',
      'isActive': true,
      'createdAt': '2024-01-20',
    },
    {
      'id': '3',
      'sheikhName': 'الشيخ علي حسن',
      'category': 'السلوك والأخلاق',
      'day': 'الثلاثاء',
      'startTime': '10:00',
      'endTime': '11:30',
      'maxStudents': 20,
      'currentStudents': 18,
      'location': 'المسجد الكبير - الطابق الأول',
      'isActive': false,
      'createdAt': '2024-01-10',
    },
    {
      'id': '4',
      'sheikhName': 'الشيخ أحمد محمد',
      'category': 'حفظ القرآن الكريم',
      'day': 'الأربعاء',
      'startTime': '16:00',
      'endTime': '18:00',
      'maxStudents': 15,
      'currentStudents': 10,
      'location': 'المسجد الكبير - الطابق الأول',
      'isActive': true,
      'createdAt': '2024-01-25',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                              'إدارة الجداول الدراسية',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إدارة جداول المحفظين والفصول الدراسية',
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

          // Stats
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي الجداول',
                      '${_schedules.length}',
                      Icons.schedule,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'الجداول النشطة',
                      '${_schedules.where((schedule) => schedule['isActive']).length}',
                      Icons.play_circle,
                      AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'إجمالي الطلاب',
                      '${_schedules.fold<int>(0, (sum, schedule) => sum + (schedule['currentStudents'] as int))}',
                      Icons.school,
                      AppTheme.infoColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Weekly Schedule View
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الجدول الأسبوعي',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklySchedule(),
                ],
              ),
            ),
          ),

          // Schedules List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'قائمة الجداول',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddScheduleDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة جدول'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._schedules.map((schedule) => _buildScheduleCard(schedule)).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule() {
    final weekDays = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final day = weekDays[index];
          final daySchedules = _schedules.where((schedule) => schedule['day'] == day).toList();
          
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                if (daySchedules.isNotEmpty)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${daySchedules.length} جدول',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${daySchedules.fold<int>(0, (sum, schedule) => sum + (schedule['currentStudents'] as int))} طالب',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'لا توجد جداول',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule['sheikhName'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule['category'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleMenuAction(value, schedule),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('تعديل'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'students',
                        child: ListTile(
                          leading: Icon(Icons.people),
                          title: Text('إدارة الطلاب'),
                        ),
                      ),
                      PopupMenuItem(
                        value: schedule['isActive'] ? 'deactivate' : 'activate',
                        child: ListTile(
                          leading: Icon(
                            schedule['isActive'] ? Icons.pause : Icons.play_arrow,
                            color: schedule['isActive'] ? Colors.orange : Colors.green,
                          ),
                          title: Text(
                            schedule['isActive'] ? 'إيقاف' : 'تفعيل',
                            style: TextStyle(
                              color: schedule['isActive'] ? Colors.orange : Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('حذف', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Schedule Details
              Row(
                children: [
                  Expanded(
                    child: _buildScheduleDetail(
                      'اليوم',
                      schedule['day'],
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScheduleDetail(
                      'الوقت',
                      '${schedule['startTime']} - ${schedule['endTime']}',
                      Icons.access_time,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScheduleDetail(
                      'المكان',
                      schedule['location'],
                      Icons.location_on,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Students Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStudentInfo(
                        'الطلاب المسجلين',
                        '${schedule['currentStudents']}',
                        Icons.people,
                        AppTheme.infoColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStudentInfo(
                        'الحد الأقصى',
                        '${schedule['maxStudents']}',
                        Icons.group_add,
                        AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStudentInfo(
                        'المقاعد المتاحة',
                        '${(schedule['maxStudents'] as int) - (schedule['currentStudents'] as int)}',
                        Icons.event_seat,
                        AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Status and Actions
              Row(
                children: [
                  _buildStatusChip(schedule['isActive']),
                  const Spacer(),
                  Text(
                    'أنشئ في: ${_formatDate(schedule['createdAt'])}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleDetail(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStatusChip(bool isActive) {
    final color = isActive ? AppTheme.successColor : Colors.grey;
    final label = isActive ? 'نشط' : 'غير نشط';
    final icon = isActive ? Icons.check_circle : Icons.pause_circle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _handleMenuAction(String action, Map<String, dynamic> schedule) {
    switch (action) {
      case 'edit':
        _showEditScheduleDialog(schedule);
        break;
      case 'students':
        _showManageStudentsDialog(schedule);
        break;
      case 'activate':
      case 'deactivate':
        _toggleScheduleStatus(schedule);
        break;
      case 'delete':
        _showDeleteConfirmation(schedule);
        break;
    }
  }

  void _showAddScheduleDialog() {
    final sheikhController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedDay = 'الأحد';
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final maxStudentsController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة جدول جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sheikhController,
                decoration: const InputDecoration(
                  labelText: 'اسم المحفظ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'الفئة التعليمية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'اليوم',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'الأحد',
                  'الاثنين',
                  'الثلاثاء',
                  'الأربعاء',
                  'الخميس',
                  'الجمعة',
                  'السبت',
                ].map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDay = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'وقت البداية',
                        border: OutlineInputBorder(),
                        hintText: '09:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'وقت النهاية',
                        border: OutlineInputBorder(),
                        hintText: '11:00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: maxStudentsController,
                      decoration: const InputDecoration(
                        labelText: 'الحد الأقصى للطلاب',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'المكان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (sheikhController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                _addSchedule(
                  sheikhController.text,
                  categoryController.text,
                  selectedDay,
                  startTimeController.text,
                  endTimeController.text,
                  maxStudentsController.text,
                  locationController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleDialog(Map<String, dynamic> schedule) {
    final sheikhController = TextEditingController(text: schedule['sheikhName']);
    final categoryController = TextEditingController(text: schedule['category']);
    String selectedDay = schedule['day'];
    final startTimeController = TextEditingController(text: schedule['startTime']);
    final endTimeController = TextEditingController(text: schedule['endTime']);
    final maxStudentsController = TextEditingController(text: schedule['maxStudents'].toString());
    final locationController = TextEditingController(text: schedule['location']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الجدول'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sheikhController,
                decoration: const InputDecoration(
                  labelText: 'اسم المحفظ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'الفئة التعليمية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDay,
                decoration: const InputDecoration(
                  labelText: 'اليوم',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'الأحد',
                  'الاثنين',
                  'الثلاثاء',
                  'الأربعاء',
                  'الخميس',
                  'الجمعة',
                  'السبت',
                ].map((day) {
                  return DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedDay = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeController,
                      decoration: const InputDecoration(
                        labelText: 'وقت البداية',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: endTimeController,
                      decoration: const InputDecoration(
                        labelText: 'وقت النهاية',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: maxStudentsController,
                      decoration: const InputDecoration(
                        labelText: 'الحد الأقصى للطلاب',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'المكان',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (sheikhController.text.isNotEmpty && categoryController.text.isNotEmpty) {
                _editSchedule(
                  schedule['id'],
                  sheikhController.text,
                  categoryController.text,
                  selectedDay,
                  startTimeController.text,
                  endTimeController.text,
                  maxStudentsController.text,
                  locationController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showManageStudentsDialog(Map<String, dynamic> schedule) {
    // Placeholder for students management dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة إدارة الطلاب قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _addSchedule(
    String sheikhName,
    String category,
    String day,
    String startTime,
    String endTime,
    String maxStudents,
    String location,
  ) {
    final newSchedule = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'sheikhName': sheikhName,
      'category': category,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'maxStudents': int.tryParse(maxStudents) ?? 15,
      'currentStudents': 0,
      'location': location,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String().split('T')[0],
    };

    setState(() {
      _schedules.add(newSchedule);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة الجدول بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _editSchedule(
    String id,
    String sheikhName,
    String category,
    String day,
    String startTime,
    String endTime,
    String maxStudents,
    String location,
  ) {
    setState(() {
      final index = _schedules.indexWhere((schedule) => schedule['id'] == id);
      if (index != -1) {
        _schedules[index]['sheikhName'] = sheikhName;
        _schedules[index]['category'] = category;
        _schedules[index]['day'] = day;
        _schedules[index]['startTime'] = startTime;
        _schedules[index]['endTime'] = endTime;
        _schedules[index]['maxStudents'] = int.tryParse(maxStudents) ?? 15;
        _schedules[index]['location'] = location;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تعديل الجدول بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _toggleScheduleStatus(Map<String, dynamic> schedule) {
    setState(() {
      schedule['isActive'] = !schedule['isActive'];
    });

    final status = schedule['isActive'] ? 'تفعيل' : 'إيقاف';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم $status الجدول بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> schedule) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'حذف الجدول',
      text: 'هل أنت متأكد من حذف الجدول؟ لا يمكن التراجع عن هذا الإجراء.',
      confirmBtnText: 'حذف',
      cancelBtnText: 'إلغاء',
      confirmBtnColor: AppTheme.errorColor,
      showCancelBtn: true,
      onConfirmBtnTap: () {
        Navigator.pop(context);
        _deleteSchedule(schedule['id']);
      },
    );
  }

  void _deleteSchedule(String id) {
    setState(() {
      _schedules.removeWhere((schedule) => schedule['id'] == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الجدول بنجاح'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
