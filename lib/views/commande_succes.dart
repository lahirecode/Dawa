import 'package:flutter/material.dart';

class CommandeSucces extends StatelessWidget {
  const CommandeSucces({super.key, this.onRetourExplorer});

  final VoidCallback? onRetourExplorer;
  static const _blue = Color(0xFF1769F5);
  static const _navy = Color(0xFF17356F);
  static const _muted = Color(0xFF60769A);

  void _retour(BuildContext context) {
    Navigator.pop(context);
    onRetourExplorer?.call();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 380;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            compact ? 16 : 20,
            12,
            compact ? 16 : 20,
            22,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => _retour(context),
                  color: _navy,
                  icon: const Icon(Icons.arrow_back, size: 26),
                ),
              ),
              const SizedBox(height: 2),
              _illustration(compact),
              const SizedBox(height: 12),
              const Text(
                'Commande confirmée !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Votre commande est en cours de préparation\n'
                'et sera bientôt en route.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 20),
              _orderInformation(),
              const SizedBox(height: 22),
              _progress(),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.location_on_outlined, size: 21),
                  label: const Text(
                    'Suivre ma commande',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite, color: _blue, size: 16),
                    SizedBox(width: 7),
                    Text(
                      'Merci de votre confiance',
                      style: TextStyle(
                        color: _blue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _illustration(bool compact) => SizedBox(
    height: compact ? 172 : 190,
    width: double.infinity,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: compact ? 205 : 240,
          height: compact ? 135 : 155,
          decoration: const BoxDecoration(
            color: Color(0xFFE3F0FF),
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          left: 22,
          bottom: 30,
          child: Icon(
            Icons.location_on,
            color: _blue.withValues(alpha: .55),
            size: 42,
          ),
        ),
        Positioned(
          right: 25,
          bottom: 42,
          child: Icon(
            Icons.location_on,
            color: _blue.withValues(alpha: .7),
            size: 40,
          ),
        ),
        Positioned(
          bottom: 23,
          child: Icon(
            Icons.delivery_dining,
            color: _blue,
            size: compact ? 100 : 116,
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            width: compact ? 64 : 70,
            height: compact ? 64 : 70,
            decoration: const BoxDecoration(
              color: Color(0xFF1CC3C0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 43,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _orderInformation() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE4EDF9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D1769F5),
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: const Column(
      children: [
        _InfoRow(label: 'N° de commande', value: '#DAWA45872'),
        _InfoRow(label: 'Date', value: '28 mai 2025 - 09:42'),
        _InfoRow(label: 'Livraison estimée', value: "Aujourd'hui - 10:30"),
      ],
    ),
  );

  Widget _progress() => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _ProgressStep(icon: Icons.check, label: 'Validée', active: true),
      _ProgressLine(active: true),
      _ProgressStep(
        icon: Icons.calendar_month,
        label: 'En préparation',
        active: true,
      ),
      _ProgressLine(),
      _ProgressStep(icon: Icons.local_shipping_outlined, label: 'En livraison'),
      _ProgressLine(),
      _ProgressStep(icon: Icons.keyboard_arrow_down, label: 'Livrée'),
    ],
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF60769A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF17356F),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.icon,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    child: Column(
      children: [
        Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: active ? const Color(0xFF1769F5) : const Color(0xFFEAF2FC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : const Color(0xFFA8BDD8),
            size: 16,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            color: active ? const Color(0xFF1769F5) : const Color(0xFF8EA4C1),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ProgressLine extends StatelessWidget {
  const _ProgressLine({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 2,
      margin: const EdgeInsets.only(top: 14),
      color: active ? const Color(0xFF1769F5) : const Color(0xFFDCE8F6),
    ),
  );
}
