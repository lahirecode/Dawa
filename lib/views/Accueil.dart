import 'package:flutter/material.dart';

import 'explorer.dart';
import 'navigation.dart';
import 'profil.dart';
import 'medecin.dart';
import '../modele/produit.dart';
import '../services/auth_session.dart';
import '../theme/app_colors.dart';
import '../widgets/app_brand.dart';
import '../widgets/app_card.dart';
import '../widgets/app_searcher.dart';

class Accueil extends StatefulWidget {
  const Accueil({super.key});

  @override
  State<Accueil> createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> {
  int _selectedIndex = 0;
  final _searchController = TextEditingController();
  final List<Produit> _panier = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.pageBackground,
    body: SafeArea(
      child: _selectedIndex == 0
          ? _home()
          : _selectedIndex == 1
          ? Explorer(
              initialIndex: 0,
              showNavigation: false,
              initialSearch: _searchController.text,
              panier: _panier,
              onPanierChanged: _remplacerPanier,
            )
          : _selectedIndex == 2
          ? Explorer(
              initialIndex: 1,
              showNavigation: false,
              panier: _panier,
              onPanierChanged: _remplacerPanier,
            )
          : _selectedIndex == 3
          ? const AuthGate(child: MedecinPage())
          : const AuthGate(child: ProfilPage()),
    ),
    bottomNavigationBar: AwaNavigationBar(
      selectedIndex: _selectedIndex,
      panierCount: _panier.length,
      onSelected: (index) => setState(() => _selectedIndex = index),
    ),
  );

  Widget _home() {
    final bannerHeight = MediaQuery.sizeOf(context).width < 380 ? 280.0 : 320.0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        SizedBox(
          height: bannerHeight,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/portfolio.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topRight,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.white.withValues(alpha: 1.0),
                          Colors.white.withValues(alpha: 0.92),
                          Colors.white.withValues(alpha: 0.5),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.45, 0.70, 0.92],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppBrand(height: 100),
                      const Spacer(),
                      const Text(
                        'Des médicaments\nde qualité à portée\nde main !',
                        style: TextStyle(
                          color: AppColors.navy,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Commandez en toute simplicité\net faites-vous livrer à domicile.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(height: 2),
        AppSearcher(
          controller: _searchController,
          onSubmitted: (_) => setState(() => _selectedIndex = 1),
          hintText: 'Rechercher un médicament...',
        ),
        const SizedBox(height: 50),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            AppCard.action(
              icon: Icons.medication,
              title: 'Médicaments',
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            AppCard.action(
              icon: Icons.description,
              title: 'Ordonnances',
              onTap: () {
                setState(() => _selectedIndex = 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Vos ordonnances seront bientôt disponibles.',
                    ),
                  ),
                );
              },
            ),
            AppCard.action(
              icon: Icons.shopping_cart,
              title: 'Panier',
              onTap: () => setState(() => _selectedIndex = 2),
              badge: _panier.isEmpty ? null : _panier.length,
            ),
            AppCard.action(
              icon: Icons.local_shipping,
              title: 'Livraison rapide',
              onTap: () {
                setState(() => _selectedIndex = 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Choisissez un médicament pour une livraison rapide.',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  void _remplacerPanier(List<Produit> produits) {
    setState(() {
      _panier
        ..clear()
        ..addAll(produits);
    });
  }
}
