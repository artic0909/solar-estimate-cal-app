import 'package:flutter/material.dart';
import '../models/customer_info.dart';
import '../widgets/calculator_form_view.dart';
import '../widgets/websol_logo.dart';
import 'user_form_screen.dart';

class CalculatorScreen extends StatelessWidget {
  final CustomerInfo customer;

  const CalculatorScreen({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF475569)),
          tooltip: 'Back to User Info',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const UserFormScreen(),
              ),
            );
          },
        ),
        title: const WebsolLogo(fontSize: 26, showTagline: false),
        centerTitle: false,
        actions: [
          // Client info pill
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 260),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 14, color: Color(0xFFF36A21)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      customer.fullName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Offline mode tag
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 13, color: Color(0xFF64748B)),
                SizedBox(width: 4),
                Text(
                  'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Single Screen Full Width (No sidebar)
      body: CalculatorFormView(customer: customer),
    );
  }
}
