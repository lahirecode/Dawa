import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../modele/produit.dart';
import '../services/auth_session.dart';
import 'Accueil.dart';
import 'Panier.dart';
import 'Productdetail.dart';
import 'medecin.dart';
import 'navigation.dart';
import 'profil.dart';

class Explorer extends StatefulWidget {
  const Explorer({
    super.key,
    this.initialIndex = 0,
    this.showNavigation = true,
    this.initialSearch = '',
    this.panier,
    this.onPanierChanged,
  });

  final int initialIndex;
  final bool showNavigation;
  final String initialSearch;
  final List<Produit>? panier;
  final ValueChanged<List<Produit>>? onPanierChanged;

  @override
  State<Explorer> createState() => _ExplorerState();
}

class _ExplorerState extends State<Explorer> {
  static const _blue = Color(0xFF6075ED);
  final _rechercheController = TextEditingController();
  late final List<Produit> _panier;
  List<Produit> _stock = [];
  String _recherche = '';
  String? _specialite;
  String? _forme;
  String? _categorie;
  bool _uniquementDisponibles = false;
  late int _navigationIndex;
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _navigationIndex = widget.initialIndex;
    _panier = widget.panier ?? <Produit>[];
    _recherche = widget.initialSearch;
    _rechercheController.text = widget.initialSearch;
    _chargerStock();
  }

  Future<void> _chargerStock() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('nom')
          .get();
      final produits = snapshot.docs.map(Produit.fromDoc).toList();
      if (!mounted) return;
      setState(() {
        _stock = produits;
        _chargement = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _chargement = false);
    }
  }

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  List<Produit> get _produitsFiltres => _stock.where((produit) {
    final terme = _recherche.trim().toLowerCase();
    final texteProduit =
        '${produit.nom} ${produit.description} ${produit.details} ${produit.categorie} ${produit.specialite} ${produit.forme}'
            .toLowerCase();
    return (terme.isEmpty ||
            produit.nom.toLowerCase().contains(terme) ||
            texteProduit.contains(terme)) &&
        (_specialite == null || produit.specialite == _specialite) &&
        (_forme == null || produit.forme == _forme) &&
        (_categorie == null || produit.categorie == _categorie) &&
        (!_uniquementDisponibles || produit.stock > 0);
  }).toList();

  bool get _filtresActifs =>
      _specialite != null ||
      _forme != null ||
      _categorie != null ||
      _uniquementDisponibles;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: _contenu()),
    bottomNavigationBar: widget.showNavigation
        ? AwaNavigationBar(
            selectedIndex: _navigationIndex + 1,
            panierCount: _panier.length,
            onSelected: _onNavigationSelected,
          )
        : null,
  );

  void _onNavigationSelected(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Accueil()),
      );
      return;
    }
    if (index == 1) {
      setState(() => _navigationIndex = 0);
    } else if (index == 2) {
      setState(() => _navigationIndex = 1);
    } else if (index == 3) {
      setState(() => _navigationIndex = 2);
    } else {
      setState(() => _navigationIndex = 3);
    }
  }

  Widget _contenu() {
    if (_navigationIndex == 1) {
      return Panier(
        produits: _panier,
        integre: true,
        onChanged: _remplacerPanier,
        onRetourExplorer: () => setState(() => _navigationIndex = 0),
      );
    }
    if (_navigationIndex == 2) {
      return const AuthGate(child: MedecinPage());
    }
    if (_navigationIndex == 3) {
      return const AuthGate(child: ProfilPage());
    }
    return _explorer();
  }

  Widget _explorer() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 12, 0),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: _blue, size: 27),
              tooltip: 'Retour',
            ),
            const Expanded(
              child: Text(
                'Médicaments',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF17356F),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Badge(
              isLabelVisible: _panier.isNotEmpty,
              label: Text('${_panier.length}'),
              backgroundColor: const Color(0xFFFF3D57),
              child: IconButton(
                onPressed: () => setState(() => _navigationIndex = 1),
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: _blue,
                  size: 28,
                ),
                tooltip: 'Panier',
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(36, 7, 28, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _rechercheController,
                onChanged: (value) => setState(() => _recherche = value),
                decoration: InputDecoration(
                  hintText: 'Rechercher un médicament...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8AA0C0),
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF7590B9),
                    size: 22,
                  ),
                  suffixIcon: _recherche.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _effacerRecherche,
                          icon: const Icon(Icons.cancel, size: 18),
                        ),
                  filled: true,
                  fillColor: const Color(0xFFF7FAFE),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE4ECF7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: Color(0xFFE4ECF7)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Badge(
              isLabelVisible: _filtresActifs,
              child: IconButton.filled(
                onPressed: _ouvrirFiltres,
                icon: const Icon(Icons.tune, size: 21),
                style: IconButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(44, 44),
                ),
                tooltip: 'Filtrer les médicaments',
              ),
            ),
          ],
        ),
      ),
      _categoriesBar(),
      Expanded(child: _contenuStock()),
    ],
  );

  Widget _categoriesBar() {
    final categories = <String>[
      'Tous',
      ..._stock.map((p) => p.categorie).toSet(),
    ];
    return SizedBox(
      height: 49,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 5),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final category = categories[index];
          final selected = index == 0
              ? !_filtresActifs
              : _categorie == category;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            onSelected: (_) => setState(() {
              _categorie = index == 0 ? null : category;
            }),
            selectedColor: _blue,
            backgroundColor: const Color(0xFFF5F8FD),
            labelStyle: TextStyle(
              color: selected ? Colors.white : const Color(0xFF49658D),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _contenuStock() {
    if (_chargement) {
      return const Center(child: CircularProgressIndicator(color: _blue));
    }
    if (_stock.isEmpty) {
      return _messageVide(
        Icons.inventory_2_outlined,
        'Stock non disponible',
        'Aucun médicament n’est enregistré dans la base de données.',
      );
    }
    if (_produitsFiltres.isEmpty) {
      return _messageVide(
        Icons.search_off,
        'Produit non disponible',
        'Aucun médicament ne correspond à votre recherche.',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
        itemCount: _produitsFiltres.length,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: constraints.maxWidth < 420 ? 165 : 190,
          crossAxisSpacing: constraints.maxWidth < 420 ? 8 : 12,
          mainAxisSpacing: 10,
          childAspectRatio: constraints.maxWidth < 420 ? .58 : .64,
        ),
        itemBuilder: (_, index) => _carteProduit(_produitsFiltres[index]),
      ),
    );
  }

  Widget _carteProduit(Produit produit) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 125;
      final imageHeight = compact ? 62.0 : 82.0;
      final titleSize = compact ? 9.0 : 11.0;
      final detailSize = compact ? 7.0 : 8.0;
      final priceSize = compact ? 11.0 : 14.0;
      return InkWell(
        onTap: () => _ouvrirDetail(produit),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.fromLTRB(compact ? 6 : 9, 8, compact ? 6 : 9, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x120B4A9B),
                blurRadius: 9,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => _ouvrirDetail(produit),
                    child: Image.asset(
                      produit.image,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: imageHeight,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.medication,
                        size: compact ? 38 : 48,
                        color: _blue,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                produit.nom,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF17356F),
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                produit.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF7890B1),
                  fontSize: detailSize,
                ),
              ),
              Text(
                '${produit.specialite} • ${produit.forme}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF7890B1),
                  fontSize: detailSize - 1,
                ),
              ),
              Text(
                produit.stock > 0 ? 'En stock' : 'Rupture de stock',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: produit.stock > 0
                      ? const Color(0xFF24A36B)
                      : Colors.red,
                  fontSize: detailSize - 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    '\$${produit.prix.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Color(0xFF17356F),
                      fontSize: priceSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton.filled(
                    onPressed: produit.stock > 0
                        ? () => _ajouterAuPanier(produit)
                        : null,
                    icon: const Icon(Icons.add, size: 17),
                    style: IconButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(compact ? 25 : 29, compact ? 25 : 29),
                      maximumSize: Size(compact ? 25 : 29, compact ? 25 : 29),
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _messageVide(IconData icon, String titre, String sousTitre) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 68, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            titre,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            sousTitre,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    ),
  );

  void _effacerRecherche() {
    _rechercheController.clear();
    setState(() => _recherche = '');
  }

  void _ajouterAuPanier(Produit produit) {
    if (produit.stock <= 0) {
      _message('Ce produit est en rupture de stock.');
      return;
    }
    setState(() => _panier.add(produit));
    widget.onPanierChanged?.call([..._panier]);
    _message('${produit.nom} ajouté au panier');
  }

  void _remplacerPanier(List<Produit> produits) {
    setState(() {
      _panier
        ..clear()
        ..addAll(produits);
    });
    widget.onPanierChanged?.call([..._panier]);
  }

  Future<void> _ouvrirDetail(Produit produit) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Productdetail(
          produit: produit,
          onAjouter: () => _ajouterAuPanier(produit),
        ),
      ),
    );
    _chargerStock();
  }

  Future<void> _ouvrirFiltres() async {
    String? specialite = _specialite;
    String? forme = _forme;
    String? categorie = _categorie;
    bool disponibles = _uniquementDisponibles;
    final specialites = _stock.map((p) => p.specialite).toSet().toList()
      ..sort();
    final formes = _stock.map((p) => p.forme).toSet().toList()..sort();
    final categories = _stock.map((p) => p.categorie).toSet().toList()..sort();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'Filtrer les médicaments',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                _filtreDropdown(
                  'Spécialité médicale',
                  specialites,
                  specialite,
                  (value) => setModalState(() => specialite = value),
                ),
                _filtreDropdown(
                  'Forme',
                  formes,
                  forme,
                  (value) => setModalState(() => forme = value),
                ),
                _filtreDropdown(
                  'Catégorie',
                  categories,
                  categorie,
                  (value) => setModalState(() => categorie = value),
                ),
                SwitchListTile(
                  value: disponibles,
                  onChanged: (value) =>
                      setModalState(() => disponibles = value),
                  title: const Text('Produits disponibles uniquement'),
                  activeThumbColor: _blue,
                  contentPadding: EdgeInsets.zero,
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setModalState(() {
                          specialite = null;
                          forme = null;
                          categorie = null;
                          disponibles = false;
                        }),
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _specialite = specialite;
                            _forme = forme;
                            _categorie = categorie;
                            _uniquementDisponibles = disponibles;
                          });
                          Navigator.pop(sheetContext);
                        },
                        style: FilledButton.styleFrom(backgroundColor: _blue),
                        child: const Text('Appliquer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filtreDropdown(
    String label,
    List<String> values,
    String? selected,
    ValueChanged<String?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: DropdownButtonFormField<String>(
      initialValue: selected,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Toutes',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: values
          .map((value) => DropdownMenuItem(value: value, child: Text(value)))
          .toList(),
      onChanged: onChanged,
    ),
  );

  void _message(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
}
