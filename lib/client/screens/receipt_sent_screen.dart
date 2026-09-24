import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'my_orders_screen.dart';

class ReceiptSentScreen extends StatefulWidget {
  const ReceiptSentScreen({super.key});

  @override
  State<ReceiptSentScreen> createState() => _ReceiptSentScreenState();
}

class _ReceiptSentScreenState extends State<ReceiptSentScreen> {
  static const Color splashRojo = Color(0xE6C32828);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7F5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 20, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {}, // ya no hay a dónde volver en este paso
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.transparent,
                    ),
                  ),
                  Text(
                    'Comprobante enviado',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: splashRojo.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.access_time_filled,
                          color: splashRojo,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '¡Comprobante enviado!',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tu pago está pendiente de aprobación. Te notificaremos cuando sea confirmado.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const MyOrdersScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: splashRojo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Ver mi pedido',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
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
}
