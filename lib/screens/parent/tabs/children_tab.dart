import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hidaya/controllers/auth_controller.dart';
import 'package:hidaya/models/child_model.dart';
import 'package:hidaya/utils/app_theme.dart';
import 'package:hidaya/providers/firebase_providers.dart';
import 'package:hidaya/widgets/loading_indicator.dart';
import 'package:hidaya/widgets/error_widget.dart' as app_error;
import 'package:hidaya/screens/parent/pages/child_profile_page.dart';

class ChildrenTab extends ConsumerWidget {
  const ChildrenTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState == null) {
      return const Center(child: Text('يرجى تسجيل الدخول'));
    }

    return Consumer(
      builder: (context, ref, child) {
        final childrenAsync = ref.watch(childrenByParentProvider(authState.id));

        return childrenAsync.when(
          data: (children) {
            if (children.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.child_care_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد أبناء مسجلين',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'قم بإضافة أبنائك للبدء في متابعة تعليمهم',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return _buildChildCard(context, child);
              },
            );
          },
          loading: () => const LoadingIndicator(),
          error: (error, stack) => app_error.AsyncErrorWidget(
            error: error,
            stackTrace: stack,
            onRetry: () => ref.refresh(childrenByParentProvider(authState.id)),
          ),
        );
      },
    );
  }

  Widget _buildChildCard(BuildContext context, ChildModel child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(2),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChildProfilePage(child: child),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      child.name[0],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'العمر: ${child.age} سنة',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            child.isApproved ? Icons.check_circle : Icons.pending,
                            size: 16,
                            color: child.isApproved
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            child.isApproved ? 'معتمد' : 'في انتظار الاعتماد',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: child.isApproved
                                      ? AppTheme.successColor
                                      : AppTheme.warningColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChildProfilePage(child: child),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
