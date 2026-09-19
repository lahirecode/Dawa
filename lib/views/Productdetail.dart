import 'package:flutter/material.dart';

import '../modele/produit.dart';

class Productdetail extends StatelessWidget {
  const Productdetail({
    super.key,
    required this.produit,
    required this.onAjouter,
  });

  final Produit produit;
  final VoidCallback onAjouter;
  static const _blue = Color(0xFF6075ED);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 380;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _blue,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, size: 28),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border, size: 29),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: (screenWidth * .72).clamp(220.0, 300.0),
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F9FE),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(38)),
            ),
            child: Image.asset(
              produit.image,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.medication, color: _blue, size: 120),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * .58,
                      child: Text(
                        produit.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF17356F),
                          fontSize: compact ? 22 : 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '\$${produit.prix.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: compact ? 19 : 25,
                        fontWeight: FontWeight.w900,
                        color: _blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  produit.description,
                  style: const TextStyle(
                    color: Color(0xFF7890B1),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFFFB51B), size: 20),
                    SizedBox(width: 5),
                    Text(
                      '4.8  •  (124 avis)',
                      style: TextStyle(
                        color: Color(0xFF49658D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    _info('Catégorie', produit.categorie),
                    _info('Stock', '${produit.stock}'),
                  ],
                ),
                const SizedBox(height: 26),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Description',
                  style: TextStyle(
                    color: Color(0xFF17356F),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  produit.details,
                  style: const TextStyle(
                    color: Color(0xFF7890B1),
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2EBF6)),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.remove, color: _blue),
                      Text(
                        '1',
                        style: TextStyle(
                          color: Color(0xFF17356F),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Icon(Icons.add, color: _blue),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: produit.stock > 0
                        ? () {
                            onAjouter();
                            Navigator.pop(context);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_cart_outlined),
                        const SizedBox(width: 10),
                        Text(
                          produit.stock > 0
                              ? 'Ajouter au panier'
                              : 'Rupture de stock',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ],
  );
}
