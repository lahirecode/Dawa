import 'package:flutter/material.dart';

import '../theme/app_button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSubmit,
    this.submitLabel = 'Enregistrer',
  });

  final String title;
  final Widget child;
  final VoidCallback? onSubmit;
  final String submitLabel;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(title, style: AppTextStyles.sectionTitle),
    content: SingleChildScrollView(child: child),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler', style: TextStyle(color: AppColors.muted)),
      ),
      AppButton(
        label: submitLabel,
        onPressed: onSubmit,
        expanded: false,
      ),
    ],
  );
}
