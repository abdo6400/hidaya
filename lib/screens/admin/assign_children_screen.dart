import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/models/schedule_group_model.dart';
import 'package:hidaya/controllers/group_children_controller.dart';
import 'package:hidaya/widgets/admin/app_scaffold.dart';
import 'package:hidaya/widgets/admin/list_item_card.dart';
import 'package:hidaya/widgets/admin/search_bar.dart' as custom;

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
    final refreshAction = IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        ref.read(allChildrenControllerProvider.notifier).loadChildren();
        ref.read(groupChildrenControllerProvider.notifier).loadItems();
      },
    );

    return AppScaffold(
      title: 'تعيين أطفال - ${widget.group.name} (${widget.group.id})',
      actions: [refreshAction],
      body: Column(
        children: [
          // Search Bar
          custom.SearchBar(
            controller: _searchController,
            hintText: 'البحث عن طفل...',
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
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
                final childrenAsync = ref.watch(allChildrenControllerProvider);

                // Get the list of children already in this group
                final groupChildrenAsync = ref.watch(
                  groupChildrenControllerProvider.select(
                    (value) => value.maybeWhen(
                      data: (groupChildren) => groupChildren,
                      orElse: () => <ChildModel>[],
                    ),
                  ),
                );

                // Load children for the group when the screen is first built
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(groupChildrenControllerProvider.notifier).loadItems();
                });

                return childrenAsync.when(
                  loading: () => const LoadingIndicator(),
error: (error, stack) =>
                      ErrorMessage(
                        message: 'حدث خطأ: $error',
                        onRetry: () {
                          ref.read(allChildrenControllerProvider.notifier).loadChildren();
                          ref.read(groupChildrenControllerProvider.notifier).loadItems();
                        },
                      ),
                  data: (children) {
                    // Get the list of child IDs already in this group
                    final groupChildIds = groupChildrenAsync.map((child) => child.id).toSet();
                    
                    // Filter children based on search query and group membership
                    final filteredChildren = children.where((child) {
                      final searchLower = _searchQuery.toLowerCase();
                      final matchesSearch = child.name.toLowerCase().contains(searchLower) ||
                          child.id.toLowerCase().contains(searchLower);
                      
                      // Check if child is already in this group
                      final isInGroup = groupChildIds.contains(child.id);
                      
                      return matchesSearch && !isInGroup;
                    }).toList()
                    ..sort((a, b) => a.name.compareTo(b.name));

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
                                  : 'لا توجد نتائج',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'جرب استخدام كلمات بحث مختلفة',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredChildren.length,
                      itemBuilder: (context, index) {
                        final child = filteredChildren[index];
                        final isSelected = _selectedChildIds.contains(child.id);

                        return ListItemCard(
                          title: child.name,
                          subtitle: 'العمر: ${child.age} سنوات',
                          trailingText: 'ID: ${child.id}',
                          selected: isSelected,
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              child.name.substring(0, 1),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedChildIds.remove(child.id);
                              } else {
                                _selectedChildIds.add(child.id);
                              }
                            });
                          },
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
          color: Theme.of(context).scaffoldBackgroundColor,
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
              child: ElevatedButton(
                onPressed: _selectedChildIds.isNotEmpty ? _assignSelectedChildren : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('تعيين المحددين (${_selectedChildIds.length})'),
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
