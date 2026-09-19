import 'package:flutter/material.dart';

import '../modele/produit.dart';
import 'checkout.dart';
import 'commande_succes.dart';

class Panier extends StatefulWidget {
  const Panier({
    super.key,
    required this.produits,
    this.integre = false,
    this.onRetourExplorer,
    this.onChanged,
  });

  final List<Produit> produits;
  final bool integre;
  final VoidCallback? onRetourExplorer;
  final ValueChanged<List<Produit>>? onChanged;

  @override
  State<Panier> createState() => _PanierState();
}

class _PanierState extends State<Panier> {
  static const _blue = Color(0xFF6075ED);
  late final List<Produit> _produits;
  final _codePromoController = TextEditingController();
  String _codePromo = '';

  @override
  void initState() {
    super.initState();
    _produits = [...widget.produits];
  }

  @override
  void dispose() {
    _codePromoController.dispose();
    super.dispose();
  }

  List<_PanierLigne> get _lignes {
    final lignes = <String, _PanierLigne>{};
    for (final produit in _produits) {
      final key = produit.id ?? produit.nom;
      final ligne = lignes[key];
      if (ligne == null) {
        lignes[key] = _PanierLigne(produit: produit, quantite: 1);
      } else {
        ligne.quantite++;
      }
    }
    return lignes.values.toList();
  }

  double get _total => _lignes.fold(
    0,
    (total, ligne) => total + ligne.produit.prix * ligne.quantite,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _cartHeader(),
            Expanded(
              child: _produits.isEmpty
                  ? _empty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      itemCount: _lignes.length + 1,
                      separatorBuilder: (_, _) => const Divider(height: 26),
                      itemBuilder: (_, index) => index < _lignes.length
                          ? _ligne(_lignes[index])
                          : _summary(),
                    ),
            ),
            if (_produits.isNotEmpty) _paymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _cartHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 14, 8),
    child: Row(
      children: [
        if (!widget.integre)
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: _blue),
          ),
        Expanded(
          child: Text(
            'Mon panier (${_produits.length})',
            style: const TextStyle(
              color: Color(0xFF17356F),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: _produits.isEmpty
              ? null
              : () {
                  setState(() => _produits.clear());
                  widget.onChanged?.call([..._produits]);
                },
          icon: const Icon(Icons.delete_outline, color: _blue, size: 25),
          tooltip: 'Vider le panier',
        ),
      ],
    ),
  );

  Widget _paymentButton() => Padding(
    padding: const EdgeInsets.fromLTRB(22, 10, 22, 20),
    child: SizedBox(
      width: double.infinity,
      height: 60,
      child: FilledButton(
        onPressed: _ouvrirCheckout,
        style: FilledButton.styleFrom(
          backgroundColor: _blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_outlined, size: 22),
            const SizedBox(width: 10),
            const Text(
              'Passer la commande',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _summary() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.sell_outlined, color: _blue, size: 20),
            SizedBox(width: 8),
            Text(
              'Code promo',
              style: TextStyle(color: _blue, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _codePromoController,
              decoration: InputDecoration(
                hintText: 'Saisir votre code',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8AA0C0),
                ),
                filled: true,
                fillColor: const Color(0xFFF7FAFE),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: const BorderSide(color: Color(0xFFE2EBF6)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () =>
                setState(() => _codePromo = _codePromoController.text.trim()),
            style: FilledButton.styleFrom(
              backgroundColor: _blue,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Text('Appliquer'),
          ),
        ],
      ),
      if (_codePromo.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Code $_codePromo appliqué',
            style: const TextStyle(color: Color(0xFF24A36B), fontSize: 12),
          ),
        ),
      const SizedBox(height: 20),
      _totalLine('Sous-total', '\$${_total.toStringAsFixed(2)}'),
      const SizedBox(height: 8),
      _totalLine('Frais de livraison', '\$2.00'),
      const Divider(height: 24),
      _totalLine('Total', '\$${(_total + 2).toStringAsFixed(2)}', strong: true),
    ],
  );

  Widget _totalLine(String label, String value, {bool strong = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: strong ? const Color(0xFF17356F) : const Color(0xFF49658D),
            fontSize: strong ? 19 : 13,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: strong ? _blue : const Color(0xFF17356F),
          fontSize: strong ? 20 : 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );

  Widget _ligne(_PanierLigne ligne) {
    final produit = ligne.produit;
    final compact = MediaQuery.sizeOf(context).width < 380;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            produit.image,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.medication, color: _blue, size: 45),
          ),
        ),
        SizedBox(width: compact ? 9 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                produit.nom,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                produit.description,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${produit.prix.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _quantityButton(Icons.remove, () => _diminuer(produit)),
                  SizedBox(
                    width: 34,
                    child: Center(
                      child: Text(
                        '${ligne.quantite}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  _quantityButton(
                    Icons.add,
                    ligne.quantite < produit.stock
                        ? () => _augmenter(produit)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _supprimerProduit(produit),
          icon: const Icon(Icons.close, color: Colors.grey, size: 25),
        ),
      ],
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback? onPressed) => SizedBox(
    width: 34,
    height: 34,
    child: IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 19),
      color: _blue,
      style: IconButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  void _augmenter(Produit produit) {
    final ligne = _lignes.firstWhere((item) => item.produit == produit);
    if (ligne.quantite < produit.stock) {
      setState(() => _produits.add(produit));
      widget.onChanged?.call([..._produits]);
    }
  }

  void _diminuer(Produit produit) {
    final index = _produits.lastIndexOf(produit);
    if (index >= 0) {
      setState(() => _produits.removeAt(index));
      widget.onChanged?.call([..._produits]);
    }
  }

  void _supprimerProduit(Produit produit) {
    setState(() => _produits.removeWhere((item) => item == produit));
    widget.onChanged?.call([..._produits]);
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 72),
        const SizedBox(height: 14),
        const Text(
          'Votre panier est vide',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ajoutez des produits depuis Explorer',
          style: TextStyle(color: Colors.grey),
        ),
        if (!widget.integre)
          TextButton(
            onPressed: () => Navigator.pop(context, _produits),
            child: const Text('Retour à Explorer'),
          ),
      ],
    ),
  );

  Future<void> _ouvrirCheckout() async {
    final commandePayee = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Checkout(totalProduits: _total),
    );
    if (!mounted || commandePayee != true) return;
    setState(() => _produits.clear());
    widget.onChanged?.call([..._produits]);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CommandeSucces(onRetourExplorer: widget.onRetourExplorer),
      ),
    );
  }
}

class _PanierLigne {
  _PanierLigne({required this.produit, required this.quantite});

  final Produit produit;
  int quantite;
}
