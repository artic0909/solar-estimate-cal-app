import 'package:flutter/material.dart';
import '../models/customer_info.dart';
import '../screens/welcome_screen.dart';
import 'websol_logo.dart';

class TabletScaffold extends StatefulWidget {
  final CustomerInfo? customer;

  const TabletScaffold({
    super.key,
    this.customer,
  });

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideTablet = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: Row(
        children: [
          // Tablet Navigation Rail / Sidebar
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: isWideTablet,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
              child: isWideTablet
                  ? const WebsolLogo(fontSize: 22, showTagline: true)
                  : const WebsolLogo(fontSize: 16, showTagline: false),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: IconButton(
                    icon: const Icon(Icons.home_outlined),
                    tooltip: 'Return to Welcome Screen',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: Text('Calculator'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: Text('Estimates'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

          const VerticalDivider(thickness: 1, width: 1),

          // Main Tablet Content Canvas
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  _selectedIndex == 0
                      ? 'Solar Calculator'
                      : _selectedIndex == 1
                          ? 'Saved Estimates'
                          : 'Settings',
                ),
                actions: [
                  if (widget.customer != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person,
                              size: 15, color: Color(0xFFF36A21)),
                          const SizedBox(width: 6),
                          Text(
                            widget.customer!.fullName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.customer!.phoneNumber,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  IconButton(
                    icon: const Icon(Icons.notifications_none_rounded),
                    tooltip: 'Notifications',
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  const CircleAvatar(
                    radius: 16,
                    child: Icon(Icons.person, size: 18),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calculate_rounded,
                                size: 56,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              widget.customer != null
                                  ? 'Proposal for ${widget.customer!.fullName}'
                                  : 'Solar Calculator Workspace',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.customer != null
                                  ? 'Email: ${widget.customer!.emailAddress} • Phone: ${widget.customer!.phoneNumber}\nCustomer registered offline. Ready for calculation parameters.'
                                  : 'Empty tablet-first setup configured.\nReady for your solar calculator screens and features.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.blueGrey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
