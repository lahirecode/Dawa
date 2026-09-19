import 'package:flutter/material.dart';

class AppBrand extends StatelessWidget {
  const AppBrand({
    super.key,
    this.height = 60,
    this.asset = 'assets/images/logo1.png',
  });

  final double height;
  final String asset;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    height: height,
    errorBuilder: (_, _, _) =>
        const Icon(Icons.medication, color: Color(0xFF1769F5), size: 48),
  );
}
