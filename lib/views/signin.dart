import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/db_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/app_brand.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  static const List<Map<String, String>> _pays = [
    {'code': '+243', 'label': 'RDC'},
    {'code': '+225', 'label': 'CI'},
    {'code': '+237', 'label': 'CA'},
    {'code': '+221', 'label': 'SE'},
    {'code': '+33', 'label': 'FR'},
    {'code': '+1', 'label': 'US'},
    {'code': '+44', 'label': 'UK'},
    {'code': '+234', 'label': 'NA'},
    {'code': '+971', 'label': 'EAU'},
    {'code': '+27', 'label': 'SA'},
    {'code': '+250', 'label': 'RW'},
    {'code': '+257', 'label': 'BI'},
    {'code': '+256', 'label': 'UG'},
    {'code': '+242', 'label': 'CG'},
  ];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _db = Dbmanager();
  bool _accepted = false;
  bool _loading = false;
  String _selectedCountryCode = '+243';
  String? _createdClientId;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) {
      _message('Déconnectez-vous avant de créer un nouveau compte.');
      return;
    }
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _message('Remplissez tous les champs obligatoires.');
      return;
    }
    final email = _emailController.text.trim().toLowerCase();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _message('Saisissez une adresse e-mail valide.');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      _message('Les mots de passe ne correspondent pas.');
      return;
    }
    if (!_accepted) {
      _message('Acceptez les termes et conditions pour continuer.');
      return;
    }
    setState(() => _loading = true);
    final telephone = Dbmanager.normalizeTelephone(
      _telephoneController.text.trim(),
      _selectedCountryCode,
    );
    try {
      if (await _db.telephoneExiste(telephone)) {
        if (!mounted) return;
        setState(() => _loading = false);
        _message('Ce numéro possède déjà un compte.');
        return;
      }
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );
      final uid = credential.user!.uid;
      await FirebaseFirestore.instance.collection('clients').doc(uid).set({
        'clientId': uid,
        'uid': uid,
        'nom': _nameController.text.trim(),
        'telephone': telephone,
        'email': email,
        'role': 'client',
        'date_inscription': FieldValue.serverTimestamp(),
        'photo': null,
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'nom': _nameController.text.trim(),
        'telephone': telephone,
        'email': email,
        'role': 'client',
        'date_inscription': FieldValue.serverTimestamp(),
        'photo': null,
      });
      await credential.user!.updateDisplayName(_nameController.text.trim());
      await auth.signOut();
      if (!mounted) return;
      setState(() {
        _createdClientId = uid;
        _loading = false;
      });
      Navigator.pop(context, {'email': email, 'clientId': _createdClientId!});
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      final message = switch (error.code) {
        'email-already-in-use' =>
          'Cette adresse e-mail possède déjà un compte.',
        'invalid-email' => 'Cette adresse e-mail est invalide.',
        'weak-password' => 'Le mot de passe est trop faible.',
        _ => 'Impossible de créer le compte pour le moment.',
      };
      _message(message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message('Impossible d’enregistrer le profil client.');
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
            const AppBrand(height: 58),
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset(
                'assets/images/portfolio.png',
                height: 178,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => const SizedBox(
                  height: 178,
                  child: Icon(
                    Icons.medical_services,
                    color: AppColors.blue,
                    size: 70,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Créer un compte',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Rejoignez DAWA et profitez de tous nos services de santé.',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _nameController,
              decoration: AppTheme.inputDecoration(
                'Nom complet',
                prefix: const Icon(Icons.person_outline, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: AppTheme.inputDecoration(
                'Adresse e-mail',
                prefix: const Icon(Icons.email_outlined, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 132,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCountryCode,
                    decoration: AppTheme.inputDecoration(
                      'Pays',
                      prefix: const Icon(Icons.language, color: AppColors.navy),
                    ),
                    items: _pays
                        .map(
                          (country) => DropdownMenuItem<String>(
                            value: country['code'],
                            child: Text(
                              country['label'] ?? country['code'] ?? '',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedCountryCode = value ?? '+243';
                    }),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _telephoneController,
                    keyboardType: TextInputType.phone,
                    decoration: AppTheme.inputDecoration(
                      'Numéro de téléphone',
                      prefix: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: AppTheme.inputDecoration(
                'Mot de passe',
                prefix: const Icon(Icons.lock_outline, color: AppColors.navy),
                suffix: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: AppTheme.inputDecoration(
                'Confirmer le mot de passe',
                prefix: const Icon(Icons.lock_outline, color: AppColors.navy),
                suffix: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.muted,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Checkbox(
                  value: _accepted,
                  onChanged: (value) =>
                      setState(() => _accepted = value ?? false),
                  side: const BorderSide(
                    color: AppColors.inputBorder,
                    width: 2,
                  ),
                  checkColor: Colors.white,
                  fillColor: const WidgetStatePropertyAll(AppColors.blue),
                ),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'J’accepte les ',
                      children: [
                        TextSpan(
                          text: 'Conditions d’utilisation et la Politique de confidentialité.',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    style: TextStyle(color: AppColors.muted, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _register,
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
                label: Text(_loading ? 'Création...' : 'Créer un compte'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Vous avez déjà un compte ?  Se connecter',
                style: TextStyle(color: AppColors.blue, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
