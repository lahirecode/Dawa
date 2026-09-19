import 'package:flutter/material.dart';

import '../services/db_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_brand.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _telephoneController = TextEditingController();
  final _db = Dbmanager();
  bool _loading = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _reinitialiser() async {
    final telephone = _telephoneController.text.trim();
    if (telephone.isEmpty) {
      _message('Saisissez votre numéro de téléphone ou votre e-mail.');
      return;
    }
    setState(() => _loading = true);
    try {
      final existe = await _db.telephoneExiste(telephone);
      if (!existe) {
        _message('Aucun compte ne correspond à ce numéro.');
        return;
      }
      await _db.envoyerEmailReinitialisation(telephone);
      _message('Un lien de réinitialisation a été envoyé.');
    } catch (_) {
      _message('Impossible d’envoyer le lien de réinitialisation.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageBackground,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.blue,
                  size: 28,
                ),
              ),
            ),
            const AppBrand(height: 62),
            const SizedBox(height: 24),
            const Icon(Icons.lock_outline, color: AppColors.blue, size: 112),
            const SizedBox(height: 16),
            const Text(
              'Mot de passe oublié ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entrez votre numéro de téléphone ou adresse e-mail pour recevoir un code de réinitialisation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: AppTheme.inputDecoration(
                'Numéro de téléphone ou e-mail',
                prefix: const Icon(Icons.phone_outlined, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _reinitialiser,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.arrow_forward, size: 20),
                label: const Text('Envoyer le code'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '←  Retour à la connexion',
                style: TextStyle(
                  color: AppColors.blue,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
