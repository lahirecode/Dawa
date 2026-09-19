import 'package:flutter/material.dart';

class AwaNavigationBar extends StatelessWidget {
  const AwaNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.panierCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int panierCount;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE4F0FF),
      elevation: 8,
      surfaceTintColor: Colors.white,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? const Color(0xFF1769F5)
              : const Color.fromARGB(255, 119, 163, 235),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined, color: Color(0xFF60769A)),
          selectedIcon: Icon(Icons.home, color: Color(0xFF1769F5)),
          label: 'Accueil',
        ),
        const NavigationDestination(
          icon: Icon(Icons.search_outlined, color: Color(0xFF60769A)),
          selectedIcon: Icon(Icons.search, color: Color(0xFF1769F5)),
          label: 'Explorer',
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: panierCount > 0,
            label: Text('$panierCount'),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF60769A),
            ),
          ),
          selectedIcon: const Icon(
            Icons.shopping_cart,
            color: Color(0xFF1769F5),
          ),
          label: 'Panier',
        ),
        const NavigationDestination(
          icon: Icon(Icons.medical_services_outlined, color: Color(0xFF60769A)),
          selectedIcon: Icon(Icons.medical_services, color: Color(0xFF1769F5)),
          label: 'Consultation',
        ),
        const NavigationDestination(
          icon: Icon(Icons.person_outline, color: Color(0xFF60769A)),
          selectedIcon: Icon(Icons.person, color: Color(0xFF1769F5)),
          label: 'Compte',
        ),
      ],
    );
  }
}
