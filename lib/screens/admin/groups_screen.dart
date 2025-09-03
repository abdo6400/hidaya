import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/sheikhs_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:hidaya/services/group_children_service.dart';
import 'package:hidaya/models/child_model.dart';
import 'create_group_screen.dart';
import 'group_details_screen.dart';
import 'edit_group_screen.dart';
import 'manage_group_students_screen.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  final GroupChildrenService _groupChildrenService = GroupChildrenService();
  String? _selectedSheikhId;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(scheduleGroupsControllerProvider);
    final sheikhsAsync = ref.watch(sheikhsControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text(
            'إدارة المجموعات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // backgroundColor: AppTheme.primaryColor,
          // foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => _refreshData(),
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            // Filters Section
            _buildFiltersSection(sheikhsAsync, categoriesAsync),

            // Stats Section
            _buildStatsSection(groupsAsync),

            // Groups List
            Expanded(
              child: groupsAsync.when(
                data: (groups) => _buildGroupsList(groups),
                loading: () => const LoadingIndicator(),
                error: (error, stack) => AsyncErrorWidget(
                  error: error,
                  onRetry: () => ref.refresh(scheduleGroupsControllerProvider),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToCreateGroup(),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('إنشاء مجموعة', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(
    AsyncValue<List<AppUser>> sheikhsAsync,
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 5),
              Text(
                'تصفية المجموعات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Sheikh Filter
              Expanded(
                child: sheikhsAsync.when(
                  data: (sheikhs) => DropdownButtonFormField<String>(
                    value: _selectedSheikhId,
                    decoration: InputDecoration(
                      labelText: 'الشيخ',
                      hintText: 'اختر الشيخ',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        alignment: Alignment.center,
                        child: Text(
                          'جميع الشيوخ',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ...sheikhs
                          .where((sheikh) => sheikh.role == UserRole.sheikh)
                          .map(
                            (sheikh) => DropdownMenuItem(
                              value: sheikh.id,
                              alignment: Alignment.center,
                              child: Text(
                                sheikh.name,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedSheikhId = value;
                      });
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('خطأ في تحميل الشيوخ'),
                ),
              ),
              const SizedBox(width: 10),
              // Category Filter
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'التصنيف',
                      hintText: 'اختر التصنيف',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        alignment: Alignment.center,
                        child: Text(
                          'جميع التصنيفات',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      ...categories.map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          alignment: Alignment.center,
                          child: Text(
                            category.name,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('خطأ في تحميل التصنيفات'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue<List<ScheduleGroupModel>> groupsAsync) {
    return groupsAsync.when(
      data: (groups) {
        final filteredGroups = _filterGroups(groups);
        final activeGroups = filteredGroups.where((g) => g.isActive).length;
       

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'إجمالي المجموعات',
                  '${filteredGroups.length}',
                  Icons.groups,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  'المجموعات النشطة',
                  '$activeGroups',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
             
            ],
          ),
        );
      },
      loading: () => const LoadingIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(List<ScheduleGroupModel> groups) {
    final filteredGroups = _filterGroups(groups);

    if (filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مجموعات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'قم بإنشاء مجموعة جديدة للبدء',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(right: 6,left: 6,top: 6,bottom: 100),
      itemCount: filteredGroups.length,
      itemBuilder: (context, index) {
        final group = filteredGroups[index];
        return _buildGroupCard(group);
      },
    );
  }

  Widget _buildGroupCard(ScheduleGroupModel group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () => _viewGroupDetails(group),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.groups,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<int>(
                            future: _groupChildrenService
                                .getChildrenCountInGroup(group.id),
                            builder: (context, snapshot) {
                              final studentCount = snapshot.data ?? 0;
                              return Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$studentCount طالب',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: group.isActive
                            ? AppTheme.successColor.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: group.isActive
                              ? AppTheme.successColor.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        group.isActive ? 'نشط' : 'غير نشط',
                        style: TextStyle(
                          color: group.isActive
                              ? AppTheme.successColor
                              : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Group Info Row
                Row(
                  children: [
                    Expanded(
                      child: _buildGroupInfo(
                        Icons.schedule,
                        group.daysDisplay,
                        'الأيام',
                      ),
                    ),
                    Expanded(
                      child: _buildGroupInfo(
                        Icons.category,
                        _getCategoryName(group.categoryId),
                        'التصنيف',
                      ),
                    ),
                    Expanded(
                      child: _buildGroupInfo(
                        Icons.person,
                        _getSheikhName(group.sheikhId),
                        'الشيخ',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'عرض التفاصيل',
                        Icons.visibility,
                        AppTheme.primaryColor,
                        () => _viewGroupDetails(group),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'تعديل',
                        Icons.edit,
                        AppTheme.secondaryColor,
                        () => _editGroup(group),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        'إدارة الطلاب',
                        Icons.people,
                        AppTheme.successColor,
                        () => _manageStudents(group),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(
                        group.isActive ? 'إيقاف' : 'تفعيل',
                        group.isActive ? Icons.pause : Icons.play_arrow,
                        group.isActive
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                        () => _toggleGroupStatus(group),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupInfo(IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[600], size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onPressed,
      //  icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 10),textAlign: TextAlign.center,),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  List<ScheduleGroupModel> _filterGroups(List<ScheduleGroupModel> groups) {
    return groups.where((group) {
      if (_selectedSheikhId != null && group.sheikhId != _selectedSheikhId) {
        return false;
      }
      if (_selectedCategoryId != null &&
          group.categoryId != _selectedCategoryId) {
        return false;
      }
      return true;
    }).toList();
  }


  String _getCategoryName(String categoryId) {
    final categoriesAsync = ref.read(categoryControllerProvider);
    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == categoryId,
          orElse: () =>
              CategoryModel(id: '', name: 'غير محدد', description: ''),
        );
        return category.name;
      },
      loading: () => 'جاري التحميل...',
      error: (_, __) => 'خطأ',
    );
  }

  String _getSheikhName(String sheikhId) {
    final sheikhsAsync = ref.read(sheikhsControllerProvider);
    return sheikhsAsync.when(
      data: (sheikhs) {
        final sheikh = sheikhs.firstWhere(
          (s) => s.id == sheikhId,
          orElse: () => AppUser(
            id: '',
            name: 'غير محدد',
            username: 'unknown',
            role: UserRole.sheikh,
            status: 'active',
          ),
        );
        return sheikh.name;
      },
      loading: () => 'جاري التحميل...',
      error: (_, __) => 'خطأ',
    );
  }

  void _refreshData() {
    ref.refresh(scheduleGroupsControllerProvider);
    ref.refresh(sheikhsControllerProvider);
    ref.refresh(categoryControllerProvider);
  }

  void _navigateToCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    ).then((_) {
      _refreshData();
    });
  }

  void _viewGroupDetails(ScheduleGroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupDetailsScreen(group: group)),
    ).then((_) {
      _refreshData();
    });
  }

  void _editGroup(ScheduleGroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditGroupScreen(group: group)),
    ).then((_) {
      _refreshData();
    });
  }

  void _manageStudents(ScheduleGroupModel group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageGroupStudentsScreen(group: group),
      ),
    ).then((_) {
      _refreshData();
    });
  }

  Future<void> _toggleGroupStatus(ScheduleGroupModel group) async {
    final newStatus = !group.isActive;
    final action = newStatus ? 'تفعيل' : 'إيقاف';

    final confirmed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'تأكيد العملية',
      text: 'هل أنت متأكد من $action المجموعة "${group.name}"؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'إلغاء',
      onCancelBtnTap: () => Navigator.pop(context,false),
      onConfirmBtnTap: () async {
       Navigator.pop(context,true);  
      },
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        final updatedGroup = group.copyWith(isActive: newStatus);
        await ref
            .read(scheduleGroupsControllerProvider.notifier)
            .updateItem(updatedGroup);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم $action المجموعة بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
      
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء $action المجموعة'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
