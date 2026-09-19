import 'package:flutter/material.dart';

import 'Accueil.dart';

class Onbronding extends StatefulWidget {
  const Onbronding({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<Onbronding> createState() => _OnbrondingState();
}

class _OnbrondingState extends State<Onbronding> {
  static const _blue = Color(0xFF4B61F5);
  final _pageController = PageController();
  bool _opening = false;

  void _openApp(BuildContext context) {
    if (_opening) return;
    _opening = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Accueil()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (page) {
          if (page == 1) _openApp(context);
        },
        children: [
          _page(
            title: 'CONSULTATION EN LIGNE',
            description: 'Nos médecins spécialistes sont prêts\nà vous recevoir pour une consultation.',
            showNavigation: true,
          ),
          _page(
            title: 'PRENEZ SOIN DE VOUS',
            description: 'Accédez rapidement à vos médicaments,\nvos commandes et vos consultations.',
            showNavigation: false,
          ),
        ],
      ),
    );
  }

  Widget _page({
    required String title,
    required String description,
    required bool showNavigation,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, error, stackTrace) => Container(color: _blue),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .08),
                  Colors.black.withValues(alpha: .78),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 300,
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (_, error, stackTrace) => const Icon(
                            Icons.medication,
                            color: Colors.white,
                            size: 100,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const _ServiceLine(label: 'En Pédiatrie'),
                      const _ServiceLine(label: 'En Gynécologie'),
                      const _ServiceLine(label: 'En Médecine Interne'),
                      const SizedBox(height: 36),
                      if (showNavigation)
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _openApp(context),
                              child: const Text(
                                'Passer',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 96,
                              height: 54,
                              child: FilledButton(
                                onPressed: () => _openApp(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: _blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 34,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceLine extends StatelessWidget {
  const _ServiceLine({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: Row(
        children: [
          const Icon(
            Icons.medical_services_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
