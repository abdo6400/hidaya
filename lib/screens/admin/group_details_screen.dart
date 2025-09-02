import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/controllers/schedule_groups_controller.dart';
import 'package:hidaya/controllers/sheikhs_controller.dart';
import 'package:hidaya/controllers/category_controller.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/user_model.dart';
import 'package:hidaya/models/category_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_model.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart';
import 'package:quickalert/quickalert.dart';
import 'package:hidaya/services/group_children_service.dart';
import 'edit_group_screen.dart';
import 'manage_group_students_screen.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> {
  final GroupChildrenService _groupChildrenService = GroupChildrenService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final sheikhsAsync = ref.watch(sheikhsControllerProvider);
    final categoriesAsync = ref.watch(categoryControllerProvider);
    final childrenAsync = ref.watch(childrenControllerProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('تفاصيل المجموعة: ${widget.group.name}'),
          // backgroundColor: AppTheme.primaryColor,
          // foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: () => _editGroup(),
              icon: const Icon(Icons.edit),
              tooltip: 'تعديل',
            ),
            IconButton(
              onPressed: () => _manageStudents(),
              icon: const Icon(Icons.people),
              tooltip: 'إدارة الطلاب',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Header Card
              _buildGroupHeaderCard(sheikhsAsync, categoriesAsync),

              const SizedBox(height: 24),

              // Schedule Information
              _buildScheduleSection(),

              const SizedBox(height: 24),

              // Students Section
              _buildStudentsSection(childrenAsync),

              const SizedBox(height: 24),

              // Actions Section
              _buildActionsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeaderCard(
    AsyncValue<List<AppUser>> sheikhsAsync,
    AsyncValue<List<CategoryModel>> categoriesAsync,
  ) {
    return Card(
      elevation: 4,
        margin: EdgeInsets.all(2),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.groups,
                    color: AppTheme.primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.group.isActive
                              ? AppTheme.successColor.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.group.isActive ? 'نشط' : 'غير نشط',
                          style: TextStyle(
                            color: widget.group.isActive
                                ? AppTheme.successColor
                                : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              widget.group.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.person,
                    'الشيخ',
                    _getSheikhName(sheikhsAsync),
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.category,
                    'التصنيف',
                    _getCategoryName(categoriesAsync),
                    AppTheme.secondaryColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'تاريخ الإنشاء',
                    _formatDate(widget.group.createdAt),
                    AppTheme.successColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      elevation: 2,
        margin: EdgeInsets.all(2),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'جدول المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.group.days.isEmpty)
              Center(
                child: Text(
                  'لا توجد أيام محددة',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.group.days.length,
                itemBuilder: (context, index) {
                  final day = widget.group.days[index];
                  return _buildDaySchedule(day);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(DaySchedule day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                day.day.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (day.timeSlots.isEmpty)
            Text(
              'لا توجد مواعيد محددة',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: day.timeSlots.map((slot) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.secondaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${slot.startTime} - ${slot.endTime}',
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentsSection(AsyncValue<List<ChildModel>> childrenAsync) {
    return Card(
      elevation: 2,
        margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'الطلاب في المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const Spacer(),
                FutureBuilder<int>(
                  future: _groupChildrenService.getChildrenCountInGroup(
                    widget.group.id,
                  ),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count طالب',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<ChildModel>>(
              future: _groupChildrenService.getChildrenInGroup(widget.group.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                }

                if (snapshot.hasError) {
                  return AsyncErrorWidget(
                    error: snapshot.error!,
                    onRetry: () => setState(() {}),
                  );
                }

                final groupChildren = snapshot.data ?? [];

                if (groupChildren.isEmpty) {
                  return Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا يوجد طلاب في هذه المجموعة',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'قم بإضافة طلاب للمجموعة للبدء',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupChildren.length,
                  itemBuilder: (context, index) {
                    final child = groupChildren[index];
                    return _buildStudentItem(child);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem(ChildModel child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                child.name[0],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'عمر: ${child.age} سنة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeStudentFromGroup(child),
            icon: const Icon(Icons.remove_circle_outline),
            color: AppTheme.errorColor,
            tooltip: 'إزالة من المجموعة',
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إجراءات المجموعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _editGroup(),
                    // s
                    label: const Text('تعديل المجموعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _manageStudents(),
                    // icon: const Icon(Icons.people),
                    label: const Text('إدارة الطلاب'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleGroupStatus(),
                    // icon: Icon(
                    //   widget.group.isActive ? Icons.pause : Icons.play_arrow,
                    // ),
                    label: Text(
                      widget.group.isActive
                          ? 'إيقاف المجموعة'
                          : 'تفعيل المجموعة',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.group.isActive
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteGroup(),
                    // icon: const Icon(Icons.delete),
                    label: const Text('حذف المجموعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSheikhName(AsyncValue<List<AppUser>> sheikhsAsync) {
    return sheikhsAsync.when(
      data: (sheikhs) {
        final sheikh = sheikhs.firstWhere(
          (s) => s.id == widget.group.sheikhId,
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

  String _getCategoryName(AsyncValue<List<CategoryModel>> categoriesAsync) {
    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == widget.group.categoryId,
          orElse: () =>
              CategoryModel(id: '', name: 'غير محدد', description: ''),
        );
        return category.name;
      },
      loading: () => 'جاري التحميل...',
      error: (_, __) => 'خطأ',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupScreen(group: widget.group),
      ),
    ).then((_) {
      // Refresh the screen
      setState(() {});
    });
  }

  void _manageStudents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageGroupStudentsScreen(group: widget.group),
      ),
    ).then((_) {
      // Refresh the screen
      setState(() {});
    });
  }

  void _refreshData() {
    ref.refresh(scheduleGroupsControllerProvider);
    ref.refresh(childrenControllerProvider);
  }

  Future<void> _removeStudentFromGroup(ChildModel child) async {
    final confirmed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'إزالة الطالب',
      text: 'هل أنت متأكد من إزالة الطالب "${child.name}" من المجموعة؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'إلغاء',
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        await _groupChildrenService.removeChildFromGroup(
          child.id,
          widget.group.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إزالة الطالب "${child.name}" من المجموعة'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          // Refresh the children list
          ref.refresh(childrenControllerProvider);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء إزالة الطالب'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleGroupStatus() async {
    final newStatus = !widget.group.isActive;
    final action = newStatus ? 'تفعيل' : 'إيقاف';

    final confirmed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'تأكيد العملية',
      text: 'هل أنت متأكد من $action المجموعة "${widget.group.name}"؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'إلغاء',
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        final updatedGroup = widget.group.copyWith(isActive: newStatus);
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
          // Refresh the screen
          setState(() {});
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

  Future<void> _deleteGroup() async {
    final confirmed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'حذف المجموعة',
      text:
          'هل أنت متأكد من حذف المجموعة "${widget.group.name}"؟\nهذا الإجراء لا يمكن التراجع عنه.',
      confirmBtnText: 'نعم، احذف',
      cancelBtnText: 'إلغاء',
      confirmBtnColor: AppTheme.errorColor,
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        await ref
            .read(scheduleGroupsControllerProvider.notifier)
            .deleteItem(widget.group.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم حذف المجموعة بنجاح'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء حذف المجموعة'),
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
