import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/screens/admin/schedule_preview_screen.dart';
import '../models/user_model.dart';
import '../controllers/sheiks_controller.dart';
import '../screens/admin/manage_schedule_screen.dart';

class SheikhCard extends ConsumerWidget {
  final AppUser sheikh;
  final Function(String sheikhId) onEdit;
  const SheikhCard({super.key, required this.sheikh, required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isActive = sheikh.status == 'active';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SchedulePreviewScreen(sheikhId: sheikh.id),
          ),
        );
      },
      child: Card(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            textDirection: TextDirection.rtl,
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: isActive ? Colors.green[100] : Colors.red[100],
                child: Text(
                  sheikh.username.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      sheikh.username,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          sheikh.phone ?? '',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isActive ? "مفعل" : "غير مفعل",
                          style: TextStyle(
                            color: isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      onEdit(sheikh.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: const Text("تأكيد الحذف"),
                            content: Text("هل تريد حذف ${sheikh.username}؟"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("إلغاء"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("حذف"),
                              ),
                            ],
                          ),
                        ),
                      );
                      if (confirm == true) {
                        await ref
                            .read(sheiksControllerProvider.notifier)
                            .deleteSheikh(sheikh.id);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
