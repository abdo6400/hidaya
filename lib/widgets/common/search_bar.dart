import 'package:flutter/material.dart';
import '../../constants/index.dart';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearchChanged;
  final VoidCallback? onClear;
  final String? initialValue;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onSearchChanged,
    this.onClear,
    this.initialValue,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _isSearching = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSearching ? AppColors.primary : AppColors.lightGrey,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {
            _isSearching = value.isNotEmpty;
          });
          widget.onSearchChanged(value);
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontFamily: 'Cairo',
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _isSearching ? AppColors.primary : AppColors.textHint,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _isSearching = false;
                    });
                    widget.onSearchChanged('');
                    widget.onClear?.call();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
