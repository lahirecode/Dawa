import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/login.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child, this.allowedRoles});

  final Widget child;
  final List<String>? allowedRoles;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    AuthSession.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    if (AuthSession.isAuthenticated &&
        (widget.allowedRoles == null ||
            widget.allowedRoles!.contains(AuthSession.role))) {
      return widget.child;
    }
    if (_cancelled) {
      return Center(
        child: TextButton(
          onPressed: () => setState(() => _cancelled = false),
          child: const Text('Afficher les options de connexion'),
        ),
      );
    }
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 390),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2ECFA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x141769F5),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFEAF3FF),
              child: Icon(Icons.lock_outline, color: Color(0xFF1769F5)),
            ),
            const SizedBox(height: 14),
            const Text(
              'Accès réservé',
              style: TextStyle(
                color: Color(0xFF17356F),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous n’avez pas le droit d’accès à cette page. '
              'Connectez-vous ou inscrivez-vous pour continuer.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF60769A), height: 1.4),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _cancelled = true),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    ),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Continuer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AuthSession {
  AuthSession._();

  static bool isAuthenticated = false;
  static String? clientId;
  static String? telephone;
  static String? nom;
  static String? role;

  static Future<void> initialize() async {
    await restoreSession();
  }

  static Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    isAuthenticated = prefs.getBool('auth_is_authenticated') ?? false;
    clientId = prefs.getString('auth_clientId');
    telephone = prefs.getString('auth_telephone');
    nom = prefs.getString('auth_nom');
    role = prefs.getString('auth_role');
  }

  static Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_is_authenticated', isAuthenticated);
    if (clientId != null) {
      await prefs.setString('auth_clientId', clientId!);
    } else {
      await prefs.remove('auth_clientId');
    }
    if (telephone != null) {
      await prefs.setString('auth_telephone', telephone!);
    } else {
      await prefs.remove('auth_telephone');
    }
    if (nom != null) {
      await prefs.setString('auth_nom', nom!);
    } else {
      await prefs.remove('auth_nom');
    }
    if (role != null) {
      await prefs.setString('auth_role', role!);
    } else {
      await prefs.remove('auth_role');
    }
  }

  static Future<void> open({
    String? id,
    String? userTelephone,
    String? userName,
    String? userRole,
  }) async {
    isAuthenticated = true;
    clientId = id;
    telephone = userTelephone;
    nom = userName;
    role = userRole;
    await saveSession();
  }

  static Future<void> close() async {
    isAuthenticated = false;
    clientId = null;
    telephone = null;
    nom = null;
    role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_is_authenticated');
    await prefs.remove('auth_clientId');
    await prefs.remove('auth_telephone');
    await prefs.remove('auth_nom');
    await prefs.remove('auth_role');
  }
}
