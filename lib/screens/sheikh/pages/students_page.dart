import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/screens/sheikh/pages/child_profile_page.dart';

class SheikhStudentsPage extends ConsumerStatefulWidget {
  final String sheikhId;
  const SheikhStudentsPage({super.key, required this.sheikhId});

  @override
  ConsumerState<SheikhStudentsPage> createState() => _SheikhStudentsPageState();
}

class _SheikhStudentsPageState extends ConsumerState<SheikhStudentsPage> {
  String? _selectedGroupId;
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildGroupSelector(),
        const SizedBox(height: 16),
        Expanded(
          child: _selectedGroupId == null
              ? _placeholder('اختر مجموعة لعرض الطلاب')
              : Consumer(builder: (context, ref, _) {
                  final studentsAsync = ref.watch(childrenInGroupProvider(_selectedGroupId!));
                  return studentsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => const Center(child: Text('تعذر تحميل الطلاب')),
                    data: (students) {
                      if (students.isEmpty) return _placeholder('لا يوجد طلاب في هذه المجموعة');
                      return ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final s = students[index];
                          return ListTile(
                            tileColor: AppTheme.surfaceColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            leading: CircleAvatar(backgroundColor: AppTheme.primaryColor, child: const Icon(Icons.person, color: Colors.white)),
                            title: Text(s.name),
                            subtitle: Text('العمر: ${s.age}'),
                            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400]),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildProfilePage(
                                    sheikhId: widget.sheikhId,
                                    categoryId: _selectedCategoryId!,
                                    child: s,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }),
        ),
      ]),
    );
  }

  Widget _buildGroupSelector() {
    return Consumer(builder: (context, ref, _) {
      final groupsAsync = ref.watch(sheikhGroupsProvider(widget.sheikhId));
      return groupsAsync.when(
        loading: () => const LinearProgressIndicator(minHeight: 2),
        error: (e, st) => Text('تعذر تحميل المجموعات', style: TextStyle(color: AppTheme.errorColor)),
        data: (groups) => DropdownButtonFormField<String>(
          value: _selectedGroupId,
          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'اختر مجموعة'),
          items: groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
          onChanged: (val) {
            setState(() => _selectedGroupId = val);
            setState(() => _selectedCategoryId = groups.firstWhere((g) => g.id == val).categoryId);
          },
         
        ),
      );
    });
  }

  Widget _placeholder(String message) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.info_outline, size: 48, color: Colors.grey),
      const SizedBox(height: 8),
      Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
    ]));
  }
}


