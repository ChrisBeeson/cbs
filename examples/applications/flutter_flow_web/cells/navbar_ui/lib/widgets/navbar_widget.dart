import 'package:flutter/material.dart';
import 'package:cbs_sdk/cbs_sdk.dart';

/// Navigation bar widget that displays navigation items
class NavbarWidget extends StatefulWidget {
  final BodyBus? bus;
  final String currentScreen;
  final Function(String)? onScreenChanged;

  const NavbarWidget({
    Key? key,
    this.bus,
    required this.currentScreen,
    this.onScreenChanged,
  }) : super(key: key);

  @override
  State<NavbarWidget> createState() => _NavbarWidgetState();
}

class _NavbarWidgetState extends State<NavbarWidget> {
  final List<NavItem> _navItems = [
    NavItem(
      id: 'screen_home',
      label: 'Home',
      icon: Icons.home,
    ),
    NavItem(
      id: 'screen_monitor',
      label: 'Monitor',
      icon: Icons.monitor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: _navItems.map((item) => _buildNavItem(item)).toList(),
      ),
    );
  }

  Widget _buildNavItem(NavItem item) {
    final isActive = item.id == widget.currentScreen;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavItemTap(item.id),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: isActive ? Border(
                bottom: BorderSide(
                  color: const Color(0xFF00D4FF),
                  width: 2,
                ),
              ) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: isActive 
                    ? const Color(0xFF00D4FF)
                    : Colors.white70,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isActive 
                      ? const Color(0xFF00D4FF)
                      : Colors.white70,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavItemTap(String screenId) {
    if (screenId != widget.currentScreen) {
      widget.onScreenChanged?.call(screenId);
      _requestScreenChange(screenId);
    }
  }

  Future<void> _requestScreenChange(String screenId) async {
    if (widget.bus != null) {
      try {
        final envelope = Envelope.newRequest(
          service: 'navigation',
          verb: 'set_screen',
          schema: 'navigation.set_screen.v1',
          payload: {'screen_id': screenId},
        );

        await widget.bus!.request(envelope);
      } catch (e) {
        print('\x1B[33m[WARN] ${DateTime.now().toIso8601String()} [NavbarWidget] '
              'Failed to request screen change: $e\x1B[0m');
      }
    }
  }
}

/// Navigation item configuration
class NavItem {
  final String id;
  final String label;
  final IconData icon;

  const NavItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}
