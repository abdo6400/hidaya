import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/children_controller.dart';
import 'package:hidaya/controllers/group_children_controller.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/primary_button.dart';

class AssignChildrenScreen extends ConsumerStatefulWidget {
  final ScheduleGroupModel group;

  const AssignChildrenScreen({super.key, required this.group});

  @override
  ConsumerState<AssignChildrenScreen> createState() =>
      _AssignChildrenScreenState();
}

class _AssignChildrenScreenState extends ConsumerState<AssignChildrenScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedChildIds = {};
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _assignSelectedChildren() async {
    if (_selectedChildIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار طفل واحد على الأقل')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (String childId in _selectedChildIds) {
        await ref
            .read(groupChildrenControllerProvider.notifier)
            .assignChildToGroup(childId: childId, groupId: widget.group.id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعيين ${_selectedChildIds.length} طفل بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تعيين الأطفال: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعيين أطفال - ${widget.group.name}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'البحث عن طفل...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Selected Count
          if (_selectedChildIds.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue[50],
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'تم اختيار ${_selectedChildIds.length} طفل',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedChildIds.clear();
                      });
                    },
                    child: const Text('إلغاء التحديد'),
                  ),
                ],
              ),
            ),

          // Children List
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final childrenAsync = ref.watch(childrenControllerProvider);

                return childrenAsync.when(
                  loading: () => const LoadingIndicator(),
                  error: (error, stack) =>
                      app_error.AppErrorWidget(message: error.toString()),
                  data: (children) {
                    // Filter children based on search query
                    final filteredChildren = children.where((child) {
                      final matchesSearch = child.name.toLowerCase().contains(
                        _searchQuery,
                      );

                      // Don't show children already in this group
                      // We'll check this later when we have the group assignments
                      return matchesSearch;
                    }).toList();

                    if (filteredChildren.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.child_care_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'لا يوجد أطفال متاحين للتعيين'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredChildren.length,
                      itemBuilder: (context, index) {
                        final child = filteredChildren[index];
                        final isSelected = _selectedChildIds.contains(child.id);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedChildIds.add(child.id);
                                } else {
                                  _selectedChildIds.remove(child.id);
                                }
                              });
                            },
                            title: Text(
                              child.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('العمر: ${child.age} سنوات'),
                                Text('الأب: ${child.parentId}'),
                                // TODO: Show current groups count when we have the data
                              ],
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                child.name.substring(0, 1),
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'تعيين المحددين (${_selectedChildIds.length})',
                onPressed: _selectedChildIds.isNotEmpty
                    ? _assignSelectedChildren
                    : null,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }
}
