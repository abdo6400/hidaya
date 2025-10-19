import 'package:flutter/material.dart';
import '../../constants/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'ar';
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Settings Section
          _buildSectionHeader('إعدادات التطبيق'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('الإشعارات'),
                  subtitle: const Text('تلقي إشعارات حول التحديثات المهمة'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('الوضع الليلي'),
                  subtitle: const Text('تفعيل الوضع المظلم'),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const Divider(),
                ListTile(
                  title: const Text('حجم الخط'),
                  subtitle: Text('${_fontSize.toInt()}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _fontSize > 12
                            ? () {
                                setState(() {
                                  _fontSize -= 2;
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _fontSize < 24
                            ? () {
                                setState(() {
                                  _fontSize += 2;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionHeader('إدارة البيانات'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup, color: AppColors.primary),
                  title: const Text('نسخ احتياطي للبيانات'),
                  subtitle: const Text('حفظ نسخة احتياطية من جميع البيانات'),
                  onTap: _showBackupDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.accent),
                  title: const Text('استعادة البيانات'),
                  subtitle: const Text('استعادة البيانات من النسخة الاحتياطية'),
                  onTap: _showRestoreDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.file_download, color: AppColors.info),
                  title: const Text('تصدير البيانات'),
                  subtitle: const Text('تصدير البيانات إلى ملف Excel'),
                  onTap: _showExportDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.error),
                  title: const Text('حذف جميع البيانات'),
                  subtitle: const Text('حذف جميع البيانات نهائياً'),
                  onTap: _showDeleteAllDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('حول التطبيق'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: const Text('إصدار التطبيق'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help, color: AppColors.accent),
                  title: const Text('المساعدة والدعم'),
                  subtitle: const Text('الحصول على المساعدة'),
                  onTap: _showHelpDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: AppColors.info),
                  title: const Text('سياسة الخصوصية'),
                  subtitle: const Text('قراءة سياسة الخصوصية'),
                  onTap: _showPrivacyDialog,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description, color: AppColors.textSecondary),
                  title: const Text('شروط الاستخدام'),
                  subtitle: const Text('قراءة شروط الاستخدام'),
                  onTap: _showTermsDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نسخ احتياطي'),
        content: const Text('سيتم إنشاء نسخة احتياطية من جميع البيانات. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('إنشاء نسخة احتياطية'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استعادة البيانات'),
        content: const Text('سيتم استعادة البيانات من النسخة الاحتياطية. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم استعادة البيانات بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('استعادة'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصدير البيانات'),
        content: const Text('سيتم تصدير جميع البيانات إلى ملف Excel. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تصدير البيانات بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع البيانات'),
        content: const Text('تحذير: سيتم حذف جميع البيانات نهائياً ولا يمكن استردادها. هل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف جميع البيانات'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المساعدة والدعم'),
        content: const Text('للمساعدة والدعم، يرجى التواصل معنا عبر:\n\nالبريد الإلكتروني: support@hidaya.com\nالهاتف: +966 50 123 4567'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const Text('نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. جميع البيانات محفوظة محلياً ولا يتم مشاركتها مع أطراف ثالثة.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('شروط الاستخدام'),
        content: const Text('باستخدام هذا التطبيق، فإنك توافق على شروط الاستخدام. يرجى استخدام التطبيق بمسؤولية واحترام خصوصية الآخرين.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }
}
