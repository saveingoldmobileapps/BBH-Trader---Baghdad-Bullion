import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderId;
  final String dateTime;
  final String tradeType;
  final String amount;
  final String targetPrice;
  final String total;

  const OrderPlacedScreen({
    super.key,
    required this.orderId,
    required this.dateTime,
    required this.tradeType,
    required this.amount,
    required this.targetPrice,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(),

              SvgPicture.asset(
                "assets/svg/success_Icon.svg",
                height: 150,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 20),
              Text(
                "Order Placed!",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              /// ✅ Subtitle
              Text(
                "Your limit order has been placed and will\nexecute when the target price is reached.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              /// ✅ Order Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Color(0xff262929),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row("Order ID", orderId),
                    _row("Date & Time", dateTime),
                    _badgeRow("Trade type", tradeType),
                    _row("Amount", amount),
                    _row("Target price", targetPrice),
                    const Divider(color: Colors.white12),
                    _totalRow("Est. Total", total),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// ✅ Info Text
              Text(
                "We’ll notify you when your order is executed",
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),

              const Spacer(),

              /// ✅ Return Home Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff917330), // left
                          Color(0xFF73530d), // center (brighter)
                          Color(0xff917330), // right
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Return to home",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
          Text(
            value,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _badgeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFBBA473).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBBA473)),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: const Color(0xFFBBA473),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: const Color(0xFFBBA473),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
