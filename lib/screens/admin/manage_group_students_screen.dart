import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:quickalert/quickalert.dart';
import 'package:hidaya/services/group_children_service.dart';

class ManageGroupStudentsScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const ManageGroupStudentsScreen({super.key, required this.group});

  @override
  ConsumerState<ManageGroupStudentsScreen> createState() =>
      _ManageGroupStudentsScreenState();
}

class _ManageGroupStudentsScreenState
    extends ConsumerState<ManageGroupStudentsScreen> {
  final GroupChildrenService _groupChildrenService = GroupChildrenService();
  bool _isLoading = false;
  List<ChildModel> _selectedStudents = [];
  List<ChildModel> _availableStudents = [];
  List<ChildModel> _groupStudents = [];
  
  bool _isStudentSelected(ChildModel student) {
    return _selectedStudents.any((s) => s.id == student.id);
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final available = await _groupChildrenService.getAvailableChildren();
      final inGroup = await _groupChildrenService.getChildrenInGroup(
        widget.group.id,
      );

      setState(() {
        // Exclude students already in the group from available list
        _availableStudents = available
            .where((a) => !inGroup.any((g) => g.id == a.id))
            .toList();
        _groupStudents = inGroup;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تحميل الطلاب: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('إدارة طلاب المجموعة: ${widget.group.name}',),
            actions: [
              IconButton(
                onPressed: () => _loadStudents(),
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث',
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'إضافة طلاب', icon: Icon(Icons.person_add)),
                Tab(text: 'الطلاب الحاليون', icon: Icon(Icons.people)),
              ],
            ),
          ),
          body: _isLoading
              ? const LoadingIndicator()
              : Column(
                  children: [
                    _buildStatsSection(),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildAvailableStudentsTab(),
                          _buildGroupStudentsTab(),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'الطلاب في المجموعة',
              '${_groupStudents.length}',
              Icons.people,
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'الطلاب المتاحون',
              '${_availableStudents.length}',
              Icons.person_add,
              AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              'المحددون',
              '${_selectedStudents.length}',
              Icons.check_circle,
              AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Tabs are now in the AppBar's TabBar

  Widget _buildAvailableStudentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'البحث عن طالب...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              // TODO: implement search filtering if needed
            },
          ),
        ),
        Expanded(
          child: _availableStudents.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا يوجد طلاب متاحون',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _availableStudents.length,
                  itemBuilder: (context, index) {
                    final student = _availableStudents[index];
                    final isSelected = _isStudentSelected(student);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              if (!_isStudentSelected(student)) {
                                _selectedStudents.add(student);
                              }
                            } else {
                              _selectedStudents
                                  .removeWhere((s) => s.id == student.id);
                            }
                          });
                        },
                        title: Text(
                          student.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text('عمر: ${student.age} سنة'),
                        secondary: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              student.name[0],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        tileColor: isSelected
                            ? AppTheme.primaryColor.withOpacity(0.1)
                            : null,
                      ),
                    );
                  },
                ),
        ),
        if (_selectedStudents.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _addSelectedStudents(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('إضافة ${_selectedStudents.length} طالب'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGroupStudentsTab() {
    return _groupStudents.isEmpty
        ? Center(
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
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _groupStudents.length,
            itemBuilder: (context, index) {
              final student = _groupStudents[index];
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
                          student.name[0],
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
                            student.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'عمر: ${student.age} سنة',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeStudentFromGroup(student),
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.errorColor,
                      tooltip: 'إزالة من المجموعة',
                    ),
                  ],
                ),
              );
            },
          );
  }

  // Bottom sheets removed in favor of inline tabs

  Future<void> _addSelectedStudents() async {
    if (_selectedStudents.isEmpty) return;

    final confirmed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'إضافة طلاب',
      text: 'هل أنت متأكد من إضافة ${_selectedStudents.length} طالب للمجموعة؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'إلغاء',
      onConfirmBtnTap: () => Navigator.pop(context,true),
      onCancelBtnTap: () => Navigator.pop(context,false),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        for (final student in _selectedStudents) {
          await _groupChildrenService.assignChildToGroup(
            student.id,
            widget.group.id,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إضافة ${_selectedStudents.length} طالب للمجموعة بنجاح',
              ),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Refresh the lists
          await _loadStudents();
          setState(() {
            _selectedStudents.clear();
          });
          
          // Switch to "current students" tab to reflect changes
          final controller = DefaultTabController.of(context);
          controller.animateTo(1);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حدث خطأ أثناء إضافة الطلاب'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeStudentFromGroup(ChildModel student) async {
    final confirmed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'إزالة الطالب',
      text: 'هل أنت متأكد من إزالة الطالب "${student.name}" من المجموعة؟',
      confirmBtnText: 'نعم',
      cancelBtnText: 'إلغاء',
      onConfirmBtnTap: () => Navigator.pop(context,true),
      onCancelBtnTap: () => Navigator.pop(context,false),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);

        await _groupChildrenService.removeChildFromGroup(
          student.id,
          widget.group.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إزالة الطالب "${student.name}" من المجموعة'),
              backgroundColor: AppTheme.successColor,
            ),
          );

          // Refresh the lists
          await _loadStudents();
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
}
