import 'package:flutter/material.dart';

class ListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsetsGeometry? margin;

  const ListItemCard({
    Key? key,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: selected
          ? Theme.of(context).primaryColor.withOpacity(0.1)
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: leading,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: selected ? Theme.of(context).primaryColor : null,
              ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected
                          ? Theme.of(context).primaryColor.withOpacity(0.8)
                          : null,
                    ),
              )
            : null,
        trailing: trailing ??
            (trailingText != null
                ? Text(
                    trailingText!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    Key? key,
    this.message = 'جاري التحميل...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
