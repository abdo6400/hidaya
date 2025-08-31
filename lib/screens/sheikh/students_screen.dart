import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  String _selectedFilter = 'all';
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _students = [
    {
      'id': '1',
      'name': 'محمد أحمد علي',
      'age': 8,
      'category': 'حفظ القرآن الكريم',
      'parentName': 'أحمد علي',
      'parentPhone': '+201234567890',
      'joinDate': '2024-01-15',
      'lastAttendance': '2024-12-15',
      'attendanceRate': 95,
      'memorizationProgress': 75,
      'behaviorScore': 90,
      'isActive': true,
      'photo': null,
      'notes': 'طالب مجتهد ومتفوق في الحفظ',
      'group': 'المجموعة الأولى',
      'schedule': 'الأحد، الثلاثاء، الخميس - 9:00 صباحاً',
    },
    {
      'id': '2',
      'name': 'فاطمة أحمد علي',
      'age': 6,
      'category': 'التلاوة والتجويد',
      'parentName': 'أحمد علي',
      'parentPhone': '+201234567890',
      'joinDate': '2024-02-01',
      'lastAttendance': '2024-12-14',
      'attendanceRate': 88,
      'memorizationProgress': 60,
      'behaviorScore': 85,
      'isActive': true,
      'photo': null,
      'notes': 'تتحسن تدريجياً في التلاوة',
      'group': 'المجموعة الثانية',
      'schedule': 'الأحد، الأربعاء - 10:00 صباحاً',
    },
    {
      'id': '3',
      'name': 'علي محمد أحمد',
      'age': 9,
      'category': 'حفظ القرآن الكريم',
      'parentName': 'محمد أحمد',
      'parentPhone': '+201234567891',
      'joinDate': '2024-01-20',
      'lastAttendance': '2024-12-13',
      'attendanceRate': 92,
      'memorizationProgress': 80,
      'behaviorScore': 88,
      'isActive': true,
      'photo': null,
      'notes': 'ممتاز في الحفظ، يحتاج تحسين في السلوك',
      'group': 'المجموعة الأولى',
      'schedule': 'الأحد، الثلاثاء، الخميس - 9:00 صباحاً',
    },
    {
      'id': '4',
      'name': 'أمينة محمد علي',
      'age': 7,
      'category': 'التلاوة والتجويد',
      'parentName': 'محمد علي',
      'parentPhone': '+201234567892',
      'joinDate': '2024-03-01',
      'lastAttendance': '2024-12-12',
      'attendanceRate': 78,
      'memorizationProgress': 45,
      'behaviorScore': 82,
      'isActive': false,
      'photo': null,
      'notes': 'غائبة مؤقتاً - سفر العائلة',
      'group': 'المجموعة الثانية',
      'schedule': 'الأحد، الأربعاء - 10:00 صباحاً',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();

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
                          Icons.people,
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
                              'إدارة الطلاب',
                              style: AppTheme.islamicTitleStyle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'متابعة وإدارة الطلاب المسندين إليك',
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
                      'إجمالي الطلاب',
                      '${_students.length}',
                      Icons.people,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'الطلاب النشطون',
                      '${_students.where((student) => student['isActive']).length}',
                      Icons.check_circle,
                      AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'متوسط الحضور',
                      '${(_students.fold<double>(0, (sum, student) => sum + (student['attendanceRate'] as int)) / _students.length).round()}%',
                      Icons.trending_up,
                      AppTheme.infoColor,
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
                      hintText: 'البحث عن طالب...',
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
                            labelText: 'الحالة',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            {'value': 'all', 'label': 'جميع الحالات'},
                            {'value': 'active', 'label': 'نشط'},
                            {'value': 'inactive', 'label': 'غير نشط'},
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
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'الفئة',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: [
                            {'value': 'all', 'label': 'جميع الفئات'},
                            {'value': 'حفظ القرآن الكريم', 'label': 'حفظ القرآن الكريم'},
                            {'value': 'التلاوة والتجويد', 'label': 'التلاوة والتجويد'},
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Students List
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'قائمة الطلاب',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...filteredStudents.map((student) => _buildStudentCard(student)).toList(),
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

  Widget _buildStudentCard(Map<String, dynamic> student) {
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
                  AppTheme.primaryColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    student['name'].toString().split(' ').first[0],
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${student['age']} سنوات - ${student['category']}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المجموعة: ${student['group']}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(student['isActive']),
              ],
            ),
          ),

          // Progress Section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقدم الأكاديمي',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        'معدل الحضور',
                        '${student['attendanceRate']}%',
                        student['attendanceRate'] / 100,
                        AppTheme.successColor,
                        Icons.check_circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        'تقدم الحفظ',
                        '${student['memorizationProgress']}%',
                        student['memorizationProgress'] / 100,
                        AppTheme.infoColor,
                        Icons.book,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        'السلوك',
                        '${student['behaviorScore']}%',
                        student['behaviorScore'] / 100,
                        AppTheme.warningColor,
                        Icons.psychology,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoRow('ولي الأمر', student['parentName']),
                _buildInfoRow('رقم الهاتف', student['parentPhone']),
                _buildInfoRow('تاريخ الانضمام', student['joinDate']),
                _buildInfoRow('آخر حضور', student['lastAttendance']),
                _buildInfoRow('الجدول', student['schedule']),
                if (student['notes'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.infoColor.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.note,
                              color: AppTheme.infoColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ملاحظات',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.infoColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          student['notes'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewStudentDetails(student),
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
                        onPressed: () => _editStudent(student),
                        icon: const Icon(Icons.edit),
                        label: const Text('تعديل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondaryColor,
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

  Widget _buildStatusChip(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.successColor : AppTheme.errorColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'نشط' : 'غير نشط',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, double progress, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredStudents() {
    return _students.where((student) {
      final searchMatch = _searchController.text.isEmpty ||
          student['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
          student['parentName'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      
      final statusMatch = _selectedFilter == 'all' ||
          (_selectedFilter == 'active' && student['isActive']) ||
          (_selectedFilter == 'inactive' && !student['isActive']);
      
      final categoryMatch = _selectedCategory == 'all' ||
          student['category'] == _selectedCategory;
      
      return searchMatch && statusMatch && categoryMatch;
    }).toList();
  }

  void _viewStudentDetails(Map<String, dynamic> student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطالب: ${student['name']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('الاسم', student['name']),
              _buildDetailRow('العمر', '${student['age']} سنوات'),
              _buildDetailRow('الفئة', student['category']),
              _buildDetailRow('ولي الأمر', student['parentName']),
              _buildDetailRow('رقم الهاتف', student['parentPhone']),
              _buildDetailRow('تاريخ الانضمام', student['joinDate']),
              _buildDetailRow('المجموعة', student['group']),
              _buildDetailRow('الجدول', student['schedule']),
              if (student['notes'] != null)
                _buildDetailRow('ملاحظات', student['notes']),
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
            width: 100,
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

  void _editStudent(Map<String, dynamic> student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🚧 تعديل الطالب ${student['name']} - سيتم تنفيذها قريباً'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }
}
