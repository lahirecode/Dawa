import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageOrdonnanceWidget extends StatelessWidget {
  const MessageOrdonnanceWidget({
    super.key,
    required this.ordonnanceId,
    this.isMedecin = false,
  });
  final String ordonnanceId;
  final bool isMedecin;

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('ordonnances')
        .doc(ordonnanceId)
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text('Ordonnance indisponible');
      if (!snapshot.hasData) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        );
      }
      final data = snapshot.data!.data();
      if (data == null) return const Text('Ordonnance introuvable');
      final items = List<Map<String, dynamic>>.from(
        (data['medicaments'] ?? data['produits'] ?? const <dynamic>[]) as List,
      );
      final total = items.fold<double>(
        0,
        (sum, item) => sum + ((item['prix'] as num?)?.toDouble() ?? 0),
      );
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.receipt_long),
                  SizedBox(width: 8),
                  Text(
                    'Ordonnance médicale',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(),
              if ((data['noteMedecin'] ?? data['note'] ?? '')
                  .toString()
                  .isNotEmpty)
                Text(
                  'Note : ${(data['noteMedecin'] ?? data['note']).toString()}',
                ),
              ...items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item['nom']?.toString() ?? 'Médicament'),
                  subtitle: Text(item['posologie']?.toString() ?? ''),
                  trailing: Text('${item['prix'] ?? 0}'),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total : ${total.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
