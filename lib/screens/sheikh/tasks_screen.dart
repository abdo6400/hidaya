import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  String _selectedFilter = 'all';
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'حفظ سورة الفاتحة',
      'description': 'حفظ سورة الفاتحة مع التجويد الصحيح',
      'category': 'حفظ القرآن الكريم',
      'assignedTo': 'محمد أحمد علي',
      'assignedBy': 'الشيخ أحمد محمد',
      'dueDate': '2024-12-20',
      'status': 'in_progress',
      'priority': 'high',
      'progress': 75,
      'createdAt': '2024-12-10',
      'notes': 'الطالب يتقدم بشكل جيد في الحفظ',
      'attachments': ['ملف صوتي.mp3', 'ملف نصي.pdf'],
    },
    {
      'id': '2',
      'title': 'تلاوة سورة البقرة - الآيات 1-10',
      'description': 'تلاوة الآيات مع تطبيق قواعد التجويد',
      'category': 'التلاوة والتجويد',
      'assignedTo': 'فاطمة أحمد علي',
      'assignedBy': 'الشيخ أحمد محمد',
      'dueDate': '2024-12-18',
      'status': 'completed',
      'priority': 'medium',
      'progress': 100,
      'createdAt': '2024-12-08',
      'notes': 'تم الإنجاز بنجاح - مستوى ممتاز',
      'attachments': ['تسجيل التلاوة.mp3'],
    },
    {
      'id': '3',
      'title': 'واجب منزلي - قواعد النحو',
      'description': 'حل تمارين قواعد النحو الأساسية',
      'category': 'اللغة العربية',
      'assignedTo': 'علي محمد أحمد',
      'assignedBy': 'الشيخ أحمد محمد',
      'dueDate': '2024-12-22',
      'status': 'pending',
      'priority': 'low',
      'progress': 0,
      'createdAt': '2024-12-12',
      'notes': 'يحتاج متابعة إضافية',
      'attachments': ['كتاب التمارين.pdf'],
    },
    {
      'id': '4',
      'title': 'مراجعة سورة آل عمران',
      'description': 'مراجعة حفظ سورة آل عمران كاملة',
      'category': 'حفظ القرآن الكريم',
      'assignedTo': 'أمينة محمد علي',
      'assignedBy': 'الشيخ أحمد محمد',
      'dueDate': '2024-12-25',
      'status': 'overdue',
      'priority': 'high',
      'progress': 30,
      'createdAt': '2024-12-05',
      'notes': 'متأخرة في التسليم - تحتاج دعم إضافي',
      'attachments': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

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
                          Icons.assignment,
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
                              'إدارة المهام',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'إنشاء وإدارة المهام التعليمية للطلاب',
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
                      'إجمالي المهام',
                      '${_tasks.length}',
                      Icons.assignment,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'مكتملة',
                      '${_tasks.where((task) => task['status'] == 'completed').length}',
                      Icons.check_circle,
                      AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'قيد التنفيذ',
                      '${_tasks.where((task) => task['status'] == 'in_progress').length}',
                      Icons.pending,
                      AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search and Filters
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'البحث والتصفية',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'البحث في المهام...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedFilter,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
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
                              _selectedFilter = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'الحالة',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            {'value': 'all', 'label': 'جميع الحالات'},
                            {'value': 'pending', 'label': 'قيد الانتظار'},
                            {'value': 'in_progress', 'label': 'قيد التنفيذ'},
                            {'value': 'completed', 'label': 'مكتملة'},
                            {'value': 'overdue', 'label': 'متأخرة'},
                          ].map((item) {
                            return DropdownMenuItem(
                              value: item['value'],
                              child: Text(item['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value!;
                            });
                          },
                        ),
                      ),
                    ],
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
                      onPressed: () => _createNewTask(),
                      icon: const Icon(Icons.add),
                      label: const Text('مهمة جديدة'),
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

          // Tasks List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'قائمة المهام',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...filteredTasks.map((task) => _buildTaskCard(task)).toList(),
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
          Icon(
            icon,
            color: color,
            size: 32,
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

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(task['status']).withOpacity(0.1),
                  _getStatusColor(task['status']).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
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
                            task['title'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            task['description'],
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
                        _buildStatusChip(task['status']),
                        const SizedBox(height: 8),
                        _buildPriorityChip(task['priority']),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        'المسند إلى',
                        task['assignedTo'],
                        Icons.person,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'الفئة',
                        task['category'],
                        Icons.category,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        'تاريخ الاستحقاق',
                        task['dueDate'],
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Progress Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'التقدم',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${task['progress']}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(task['status']),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: task['progress'] / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor(task['status'])),
                  minHeight: 8,
                ),
                const SizedBox(height: 20),
                
                // Attachments
                if (task['attachments'].isNotEmpty) ...[
                  Text(
                    'المرفقات',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: task['attachments'].map<Widget>((attachment) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.infoColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.infoColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 16,
                              color: AppTheme.infoColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              attachment,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.infoColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Notes
                if (task['notes'] != null && task['notes'].isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note,
                              color: AppTheme.warningColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ملاحظات',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task['notes'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
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
                        onPressed: () => _viewTaskDetails(task),
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
                        onPressed: () => _editTask(task),
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
                        onPressed: () => _updateProgress(task),
                        icon: const Icon(Icons.update),
                        label: const Text('تحديث التقدم'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.successColor,
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

  Widget _buildPriorityChip(String priority) {
    final priorityInfo = _getPriorityInfo(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: priorityInfo['color'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priorityInfo['label'],
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
      case 'pending':
        return {'label': 'قيد الانتظار', 'color': AppTheme.warningColor};
      case 'in_progress':
        return {'label': 'قيد التنفيذ', 'color': AppTheme.infoColor};
      case 'completed':
        return {'label': 'مكتملة', 'color': AppTheme.successColor};
      case 'overdue':
        return {'label': 'متأخرة', 'color': AppTheme.errorColor};
      default:
        return {'label': 'غير محدد', 'color': Colors.grey};
    }
  }

  Map<String, dynamic> _getPriorityInfo(String priority) {
    switch (priority) {
      case 'high':
        return {'label': 'عالية', 'color': AppTheme.errorColor};
      case 'medium':
        return {'label': 'متوسطة', 'color': AppTheme.warningColor};
      case 'low':
        return {'label': 'منخفضة', 'color': AppTheme.successColor};
      default:
        return {'label': 'غير محدد', 'color': Colors.grey};
    }
  }

  Color _getStatusColor(String status) {
    return _getStatusInfo(status)['color'];
  }

  List<Map<String, dynamic>> _getFilteredTasks() {
    return _tasks.where((task) {
      final searchMatch = _searchController.text.isEmpty ||
          task['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          task['description'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          task['assignedTo'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      
      final categoryMatch = _selectedFilter == 'all' ||
          task['category'] == _selectedFilter;
      
      final statusMatch = _selectedStatus == 'all' ||
          task['status'] == _selectedStatus;
      
      return searchMatch && categoryMatch && statusMatch;
    }).toList();
  }

  void _createNewTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚧 إنشاء مهمة جديدة - سيتم تنفيذها قريباً'),
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

  void _viewTaskDetails(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المهمة: ${task['title']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('العنوان', task['title']),
              _buildDetailRow('الوصف', task['description']),
              _buildDetailRow('الفئة', task['category']),
              _buildDetailRow('المسند إلى', task['assignedTo']),
              _buildDetailRow('المسند من', task['assignedBy']),
              _buildDetailRow('تاريخ الاستحقاق', task['dueDate']),
              _buildDetailRow('الحالة', _getStatusInfo(task['status'])['label']),
              _buildDetailRow('الأولوية', _getPriorityInfo(task['priority'])['label']),
              _buildDetailRow('التقدم', '${task['progress']}%'),
              _buildDetailRow('تاريخ الإنشاء', task['createdAt']),
              if (task['notes'] != null && task['notes'].isNotEmpty)
                _buildDetailRow('ملاحظات', task['notes']),
              if (task['attachments'].isNotEmpty)
                _buildDetailRow('المرفقات', task['attachments'].join(', ')),
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

  void _editTask(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 تعديل المهمة: ${task['title']} - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  void _updateProgress(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 تحديث تقدم المهمة: ${task['title']} - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
