import 'package:flutter/material.dart';
import 'package:hidaya/utils/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final double height;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = 70,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;
              
              return Expanded(
                child: _buildNavItem(
                  item: item,
                  index: index,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomNavItem item,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 5 : 3),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                item.icon,
                color: isSelected 
                    ? Colors.white 
                    : AppTheme.primaryColor.withOpacity(0.6),
                size: isSelected ? 18 : 18,
              ),
            ),
            

            
            // Label with animation
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected 
                    ? AppTheme.primaryColor 
                    : Colors.grey[600],
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected 
                    ? FontWeight.w600 
                    : FontWeight.w500,
              ),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
           
           
          ],
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final String? route;

  const BottomNavItem({
    required this.icon,
    required this.label,
    this.route,
  });
}

// Predefined navigation items for different roles
class BottomNavItems {
  // Admin navigation items
  static const List<BottomNavItem> admin = [
    BottomNavItem(
      icon: Icons.dashboard_customize,
      label: 'لوحة التحكم',
    ),
    BottomNavItem(
      icon: Icons.group_add,
      label: 'المحفظين',
    ),
    BottomNavItem(
      icon: Icons.category_rounded,
      label: 'الفئات',
    ),
    BottomNavItem(
      icon: Icons.task,
      label: 'المهام',
    ),
    BottomNavItem(
      icon: Icons.person,
      label: 'أولياء الأمور',
    ),
  ];

  // Sheikh navigation items
  static const List<BottomNavItem> sheikh = [
    BottomNavItem(
      icon: Icons.home,
      label: 'الرئيسية',
    ),
    BottomNavItem(
      icon: Icons.people,
      label: 'الطلاب',
    ),
    BottomNavItem(
      icon: Icons.assignment,
      label: 'المهام',
    ),
    BottomNavItem(
      icon: Icons.analytics,
      label: 'التقارير',
    ),
    BottomNavItem(
      icon: Icons.schedule,
      label: 'الجدول',
    ),
  ];

  // Parent navigation items
  static const List<BottomNavItem> parent = [
    BottomNavItem(
      icon: Icons.home,
      label: 'الرئيسية',
    ),
    BottomNavItem(
      icon: Icons.child_care,
      label: 'الأبناء',
    ),
    BottomNavItem(
      icon: Icons.trending_up,
      label: 'التقدم',
    ),
    BottomNavItem(
      icon: Icons.notifications,
      label: 'الإشعارات',
    ),
  ];
}
