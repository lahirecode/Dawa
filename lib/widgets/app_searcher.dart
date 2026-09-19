import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSearcher extends StatefulWidget {
  const AppSearcher({
    super.key,
    required this.controller,
    this.hintText = 'Rechercher...',
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  State<AppSearcher> createState() => _AppSearcherState();
}

class _AppSearcherState extends State<AppSearcher> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) => TextField(
    controller: widget.controller,
    readOnly: widget.readOnly,
    onTap: widget.onTap,
    onChanged: widget.onChanged,
    onSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.search, color: AppColors.blue),
      suffixIcon: widget.controller.text.isEmpty
          ? null
          : IconButton(
              onPressed: widget.controller.clear,
              icon: const Icon(Icons.close, color: AppColors.muted),
            ),
    ),
  );
}
