import 'package:flutter/material.dart';

import '../widgets/app_form_field.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key, required this.totalProduits});

  final double totalProduits;

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  static const _blue = Color(0xFF1769F5);
  static const _navy = Color(0xFF17356F);
  static const _muted = Color(0xFF60769A);

  String _livraison = 'Livraison à domicile';
  String _paiement = 'Mobile Money';
  String _nomLivraison = 'Jean Dupont';
  String _telephoneLivraison = '+243 970 123 456';
  String _adresseLivraison = 'Avenue de la Paix, N°12\nKinshasa, Gombe';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontalPadding = width < 380 ? 16.0 : 22.0;

    return Container(
      height: MediaQuery.sizeOf(context).height * .96,
      decoration: const BoxDecoration(
        color: Color(0xFFF7FAFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  2,
                  horizontalPadding,
                  20,
                ),
                children: [
                  _sectionTitle(Icons.location_on, 'Adresse de livraison'),
                  const SizedBox(height: 10),
                  _addressCard(),
                  const SizedBox(height: 24),
                  _sectionTitle(Icons.local_shipping, 'Mode de livraison'),
                  const SizedBox(height: 10),
                  _deliveryCard(
                    title: 'Livraison à domicile',
                    subtitle: 'Livraison en 30 - 60 min',
                    trailing: '2,00 \$',
                    selected: _livraison == 'Livraison à domicile',
                    onTap: () =>
                        setState(() => _livraison = 'Livraison à domicile'),
                  ),
                  _deliveryCard(
                    title: 'Retrait en pharmacie',
                    subtitle: 'Disponible immédiatement',
                    trailing: 'Gratuit',
                    selected: _livraison == 'Retrait en pharmacie',
                    onTap: () =>
                        setState(() => _livraison = 'Retrait en pharmacie'),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(Icons.credit_card, 'Moyen de paiement'),
                  const SizedBox(height: 10),
                  _paymentCard(
                    title: 'Mobile Money',
                    subtitle: 'Airtel Money / Orange Money',
                    logos: const ['assets/icons/airtel.jpg'],
                    selected: _paiement == 'Mobile Money',
                    onTap: () => setState(() => _paiement = 'Mobile Money'),
                  ),
                  _paymentCard(
                    title: 'Carte bancaire',
                    subtitle: 'Visa / Mastercard',
                    logos: const [
                      'assets/icons/visa.jpg',
                      'assets/icons/master.jpg',
                    ],
                    selected: _paiement == 'Carte bancaire',
                    onTap: () => setState(() => _paiement = 'Carte bancaire'),
                  ),
                  _paymentCard(
                    title: 'Paiement à la livraison',
                    subtitle: 'Espèces ou mobile money',
                    selected: _paiement == 'Paiement à la livraison',
                    onTap: () =>
                        setState(() => _paiement = 'Paiement à la livraison'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _payer,
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          color: _navy,
          icon: const Icon(Icons.arrow_back, size: 25),
        ),
        const Expanded(
          child: Text(
            'Livraison',
            style: TextStyle(
              color: _navy,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(IconData icon, String title) => Row(
    children: [
      Icon(icon, color: _blue, size: 23),
      const SizedBox(width: 10),
      Text(
        title,
        style: const TextStyle(
          color: _navy,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  Widget _addressCard() => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
    decoration: _cardDecoration(),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _nomLivraison,
                style: TextStyle(
                  color: _navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                _telephoneLivraison,
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              SizedBox(height: 5),
              Text(
                _adresseLivraison,
                style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: _modifierAdresse,
          style: TextButton.styleFrom(
            foregroundColor: _blue,
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Modifier'),
        ),
      ],
    ),
  );

  Widget _deliveryCard({
    required String title,
    required String subtitle,
    required String trailing,
    required bool selected,
    required VoidCallback onTap,
  }) => _choiceCard(
    selected: selected,
    onTap: onTap,
    child: Row(
      children: [
        _radio(selected),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: _navy,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );

  Widget _paymentCard({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
    List<String> logos = const [],
  }) => _choiceCard(
    selected: selected,
    onTap: onTap,
    child: Row(
      children: [
        _radio(selected),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
            ],
          ),
        ),
        if (logos.isNotEmpty)
          Wrap(
            spacing: 5,
            children: logos
                .map(
                  (logo) => Image.asset(
                    logo,
                    width: 34,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                )
                .toList(),
          ),
      ],
    ),
  );

  Widget _choiceCard({
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFEAF3FF) : Colors.white,
        border: Border.all(
          color: selected ? const Color(0xFF8AB9FF) : const Color(0xFFE5EDF8),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    ),
  );

  Widget _radio(bool selected) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: selected ? _blue : Colors.white,
      border: Border.all(
        color: selected ? _blue : const Color(0xFFB6C9E4),
        width: 2,
      ),
    ),
    child: selected
        ? const Icon(Icons.check, color: Colors.white, size: 13)
        : null,
  );

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE3ECF8)),
    boxShadow: const [
      BoxShadow(color: Color(0x0D1769F5), blurRadius: 10, offset: Offset(0, 3)),
    ],
  );

  void _payer() {
    Navigator.pop(context, true);
  }

  Future<void> _modifierAdresse() async {
    final nomController = TextEditingController(text: _nomLivraison);
    final telephoneController = TextEditingController(
      text: _telephoneLivraison,
    );
    final adresseController = TextEditingController(text: _adresseLivraison);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier l’adresse de livraison'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppFormField(
                controller: nomController,
                label: 'Nom complet',
                textInputAction: TextInputAction.next,
              ),
              AppFormField(
                controller: telephoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                label: 'Téléphone',
              ),
              AppFormField(
                controller: adresseController,
                minLines: 2,
                maxLines: 3,
                label: 'Adresse complète',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final nom = nomController.text.trim();
              final telephone = telephoneController.text.trim();
              final adresse = adresseController.text.trim();
              if (nom.isEmpty || telephone.isEmpty || adresse.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez compléter tous les champs.'),
                  ),
                );
                return;
              }
              setState(() {
                _nomLivraison = nom;
                _telephoneLivraison = telephone;
                _adresseLivraison = adresse;
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    nomController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
  }
}
