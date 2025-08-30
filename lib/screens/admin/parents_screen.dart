import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/parents_controller.dart';
import '../../controllers/children_controller.dart';
import '../../models/user_model.dart';

class ParentsScreen extends ConsumerStatefulWidget {
  const ParentsScreen({super.key});

  @override
  ConsumerState<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends ConsumerState<ParentsScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(parentsControllerProvider.notifier).loadParents(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentsState = ref.watch(parentsControllerProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => _showAddParentDialog(context),
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "بحث بالاسم أو الهاتف...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          Expanded(
            child: parentsState.when(
              data: (parents) {
                final filtered = parents.where((p) {
                  return p.username.toLowerCase().contains(_searchQuery) ||
                      p.phone!.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text("لا يوجد أولياء أمور."));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final parent = filtered[index];
                    return _buildParentCard(parent);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("خطأ: $err")),
            ),
          ),
        ],
      ),
    );
  }

  /// ====== بطاقة عرض ولي الأمر + العمليات ======
  Widget _buildParentCard(AppUser parent) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: parent.status == "active"
              ? Colors.green
              : Colors.red,
          child: Text(parent.username[0].toUpperCase()),
        ),

        title: Text(
          parent.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${parent.phone} • ${parent.status == "active" ? "مقبول" : "قيد المراجعة"}",
        ),
        children: [
          _buildChildrenSection(parent),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              if (parent.status != "active")
                TextButton(
                  onPressed: () async {
                    await _handleOperation(
                      context,
                      () => ref
                          .read(parentsControllerProvider.notifier)
                          .acceptParent(parent.id),
                      successMessage: "تم قبول ولي الأمر",
                    );
                  },
                  child: const Text("قبول"),
                ),
              TextButton(
                onPressed: () => _showAddChildDialog(context, parent.id),
                child: const Text("إضافة طفل"),
              ),
              TextButton(
                onPressed: () async {
                  await _handleOperation(
                    context,
                    () => ref
                        .read(parentsControllerProvider.notifier)
                        .deleteParent(parent.id),
                    successMessage: "تم حذف ولي الأمر",
                  );
                },
                child: const Text("حذف ولي الأمر"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ====== قسم الأطفال ======
  Widget _buildChildrenSection(AppUser parent) {
    final childrenState = ref.watch(childrenControllerProvider(parent.id));

    return childrenState.when(
      data: (children) {
        if (children.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("لا يوجد أطفال لهذا ولي الأمر."),
          );
        }
        return Column(
          children: children.map((child) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: child.isApproved ? Colors.green : Colors.red,
                child: Text(child.age.toString()),
              ),
              title: Text(child.name),
              subtitle: Text(child.isApproved ? "مقبول" : "قيد المراجعة"),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == "approve") {
                    await _handleOperation(
                      context,
                      () => ref
                          .read(childrenControllerProvider(parent.id).notifier)
                          .approveChild(child.id),
                      successMessage: "تم قبول الطفل",
                    );
                  } else if (value == "delete") {
                    await _handleOperation(
                      context,
                      () => ref
                          .read(childrenControllerProvider(parent.id).notifier)
                          .deleteChild(child.id),
                      successMessage: "تم حذف الطفل",
                    );
                  }
                },
                itemBuilder: (context) => [
                  if (!child.isApproved)
                    const PopupMenuItem(value: "approve", child: Text("قبول")),
                  const PopupMenuItem(value: "delete", child: Text("حذف")),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("خطأ في تحميل الأطفال: $err"),
      ),
    );
  }

  /// ====== حوار إضافة طفل ======
  void _showAddChildDialog(BuildContext context, String parentId) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("إضافة طفل"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "اسم الطفل"),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "العمر"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _handleOperation(
                  context,
                  () => ref
                      .read(childrenControllerProvider(parentId).notifier)
                      .addChild(nameController.text, ageController.text),
                  successMessage: "تمت إضافة الطفل",
                );
                Navigator.pop(context);
              },
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  /// ====== حوار إضافة ولي أمر ======
  void _showAddParentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text("إضافة ولي أمر"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "اسم ولي الأمر"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "رقم الهاتف"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "كلمة المرور"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _handleOperation(
                  context,
                  () => ref
                      .read(parentsControllerProvider.notifier)
                      .addParent(
                        AppUser(
                          username: nameController.text,
                          phone: phoneController.text,
                          id: "",
                          role: UserRole.parent,
                          status: "active",
                        ),
                        passwordController.text,
                      ),
                  successMessage: "تمت إضافة ولي الأمر",
                );
                Navigator.pop(context);
              },
              child: const Text("إضافة"),
            ),
          ],
        ),
      ),
    );
  }

  /// ====== دالة عامة لإظهار التحميل + snackbar ======
  Future<void> _handleOperation(
    BuildContext context,
    Future<void> Function() operation, {
    required String successMessage,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await operation();
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ: $e")));
      }
    }
  }
}
