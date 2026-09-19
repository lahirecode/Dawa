import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../admin/dashboard.dart';
import '../admin/medecins.dart';
import '../services/auth_session.dart';
import '../services/db_manager.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';
import '../theme/app_theme.dart';
import '../widgets/app_brand.dart';
import 'explorer.dart';
import 'forgot_password.dart';
import 'signin.dart';

class Login extends StatefulWidget {
  const Login({super.key, this.initialTelephone = ''});

  final String initialTelephone;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _db = Dbmanager();
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _telephoneController.text = widget.initialTelephone;
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifiant = _telephoneController.text.trim();
    if (identifiant.isEmpty || _passwordController.text.isEmpty) {
      _message('Saisissez votre e-mail ou votre numéro et votre mot de passe.');
      return;
    }

    setState(() => _loading = true);

    Map<String, dynamic>? user;
    Map<String, dynamic>? professionnel;
    try {
      final isEmail = identifiant.contains('@');
      final normalizedPhone = isEmail
          ? null
          : Dbmanager.normalizeTelephone(identifiant);

      if (isEmail) {
        final email = identifiant.toLowerCase();
        try {
          final credential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: email,
                password: _passwordController.text,
              );
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .get();

          if (userDoc.exists) {
            final data = userDoc.data() ?? {};
            user = {
              ...data,
              'role': (data['role'] as String?) ?? 'client',
              'id': (data['id'] ?? credential.user!.uid).toString(),
            };
          } else {
            final clientDoc = await FirebaseFirestore.instance
                .collection('clients')
                .doc(credential.user!.uid)
                .get();
            if (clientDoc.exists) {
              final data = clientDoc.data() ?? {};
              user = {
                ...data,
                'role': (data['role'] as String?) ?? 'client',
                'id': (data['id'] ?? credential.user!.uid).toString(),
              };
            } else {
              final professionalDocs = await FirebaseFirestore.instance
                  .collection('professionals')
                  .where('telephone', isEqualTo: _telephoneFromEmail(email))
                  .limit(1)
                  .get();

              if (professionalDocs.docs.isNotEmpty) {
                final data = professionalDocs.docs.first.data();
                professionnel = {
                  ...data,
                  'role': (data['role'] as String?) ?? 'medecin',
                  'id': (data['id'] ?? professionalDocs.docs.first.id)
                      .toString(),
                };
              }
            }
          }
        } on FirebaseAuthException {
          user = null;
          professionnel = null;
        }
      } else {
        user = await _db.authentifierUtilisateur(
          telephone: normalizedPhone!,
          motDePasse: _passwordController.text,
        );
        professionnel = user == null
            ? await _db.authentifierProfessionnel(
                telephone: normalizedPhone,
                motDePasse: _passwordController.text,
              )
            : null;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _message('Connexion Firebase indisponible. Vérifiez votre réseau.');
      }
      return;
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null && professionnel == null) {
      _message('Identifiants incorrects. Créez un compte si nécessaire.');
      return;
    }

    final compte = user ?? professionnel!;
    final role = professionnel == null
        ? (compte['role'] as String? ?? 'client')
        : (compte['role'] as String? ?? 'client');

    await AuthSession.open(
      id: compte['id']?.toString(),
      userTelephone: compte['telephone'] as String?,
      userName: compte['nom'] as String?,
      userRole: role,
    );

    if (role == 'admin') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
      return;
    }

    if (role == 'medecin' || role == 'fournisseur') {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MedecinsPage()),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Explorer()),
    );
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _loading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!doc.exists) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nom': user.displayName ?? 'Utilisateur Google',
          'telephone': '',
          'email': user.email ?? '',
          'date_inscription': FieldValue.serverTimestamp(),
          'photo': user.photoURL ?? 'assets/images/entry.png',
        });
      }

      await AuthSession.open(
        id: user.uid,
        userTelephone: '',
        userName: user.displayName ?? 'Utilisateur Google',
        userRole: 'client',
      );

      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Explorer()),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _message('Connexion Google impossible pour le moment.');
      }
    }
  }

  String _telephoneFromEmail(String email) {
    final value = email.trim().toLowerCase();
    if (!value.contains('@')) return value;
    final raw = value.split('@').first;
    return Dbmanager.normalizeTelephone(raw);
  }

  void _openSignIn() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const Signin()),
    );
    if (!mounted || result == null) return;
    final email = result['email'];
    if (email == null || email.isEmpty) return;
    _telephoneController.text = email;
    _message('Compte créé. Connectez-vous avec votre mot de passe.');
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
        padding: const EdgeInsets.fromLTRB(33, 24, 33, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppBrand(height: 62),
            const SizedBox(height: 24),
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
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Connectez-vous', style: AppTextStyles.display),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accédez à vos médicaments, vos consultations et bien plus encore.',
              style: TextStyle(color: AppColors.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: AppTheme.inputDecoration(
                'Nom d’utilisateur ou numéro de téléphone',
                prefix: const Icon(Icons.person_outline, color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: AppTheme.inputDecoration(
                'Mot de passe',
                prefix: const Icon(Icons.lock_outline, color: AppColors.navy),
                suffix: IconButton(
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPassword()),
                ),
                child: const Text(
                  'Mot de passe oublié ?',
                  style: TextStyle(color: AppColors.blue, fontSize: 13),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _login,
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
                label: Text(_loading ? 'Connexion...' : 'Se connecter'),
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(child: Divider(color: AppColors.inputBorder)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('OU', style: TextStyle(color: AppColors.muted)),
                ),
                Expanded(child: Divider(color: AppColors.inputBorder)),
              ],
            ),
            const SizedBox(height: 14),
            _SocialButton(
              imagePath: 'assets/icons/google.jpg',
              label: 'Continuer avec Google',
              onPressed: _loginWithGoogle,
            ),
            const SizedBox(height: 10),
            _SocialButton(
              imagePath: 'assets/icons/fb.jpg',
              label: 'Continuer avec Facebook',
              onPressed: () => _message('Connexion Facebook à venir.'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _openSignIn,
              child: const Text.rich(
                TextSpan(
                  text: 'Vous n’avez pas de compte ? ',
                  children: [
                    TextSpan(
                      text: 'Créer un compte',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: TextStyle(color: AppColors.blue, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.imagePath,
    required this.label,
    required this.onPressed,
  });
  final String imagePath;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Image.asset(
      imagePath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 24),
    ),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.navy,
      minimumSize: const Size.fromHeight(42),
      side: const BorderSide(color: AppColors.inputBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
