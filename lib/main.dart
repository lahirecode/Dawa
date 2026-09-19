import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'services/auth_session.dart';
import 'theme/app_theme.dart';
import 'views/Onbronding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AuthSession.initialize();

  //try {
  //  await Dbmanager().seedFirestore();
  //} catch (error) {
  //  debugPrint('seedFirestore error: $error');
  // }

  runApp(const MonApplication());
}

class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dawa Santé',
      theme: AppTheme.light,
      home: const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _blinkController.repeat(reverse: true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const Onbronding(imagePath: 'assets/images/entry.png'),
        ),
      );
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(begin: const Offset(0, -1.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
    return Scaffold(
      backgroundColor: const Color(0xFF1769F5),
      body: Center(
        child: SlideTransition(
          position: slide,
          child: FadeTransition(
            opacity: Tween<double>(begin: .35, end: 1).animate(
              CurvedAnimation(
                parent: _blinkController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  width: 200,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (_, error, stackTrace) => const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 90,
                  ),
                ),
                const SizedBox(height: 18),
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
