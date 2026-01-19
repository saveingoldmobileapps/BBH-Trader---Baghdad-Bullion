import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/gift_provider/gift_fund_provider.dart';

import '../main_home_screens/main_home_screen.dart';

class GiftSuccessScreen extends ConsumerStatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverEmail;
  final String receiverPhoneNumber;
  final String giftAmount;
  final String paymentMethod;
  final String comment;
  List<Map<String, dynamic>>? selectedDealsData;

  GiftSuccessScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    required this.receiverPhoneNumber,
    required this.giftAmount,
    required this.paymentMethod,
    required this.comment,
    this.selectedDealsData,
  });

  @override
  ConsumerState createState() => _GiftSuccessScreenState();
}

class _GiftSuccessScreenState extends ConsumerState<GiftSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(giftProvider.notifier)
          .createGift(
            receiverEmail: widget.receiverEmail,
            receiverId: widget.receiverId,
            receiverName: widget.receiverName,
            receiverPhoneNumber: widget.receiverPhoneNumber,
            paymentMethod: widget.paymentMethod,
            giftAmount: widget.giftAmount,
            context: context,
            comment: widget.comment,
            selectedDealsData: widget.selectedDealsData,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    sizes!.refreshSize(context);
    final giftState = ref.watch(giftProvider);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MainHomeScreen()),
          (_) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.greyScale1000,
        body: giftState.loadingState == LoadingState.loading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// SUCCESS ICON
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2ED573),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2ED573).withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 48,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// TITLE
                      const Text(
                        "Gift sent!",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// DESCRIPTION
                      Text(
                        "You’ve successfully sent ${widget.giftAmount}g gold gift to ${widget.receiverName}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade400,
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// SUMMARY CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222524),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Summary",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _summaryRow("ID", "#GLD5QUF3K"),
                            _divider(),
                            _summaryRow(
                              "Date & Time",
                              "Dec 13, 2025, 07:02 PM",
                            ),
                            _divider(),
                            _summaryRow(
                              "Amount",
                              "${widget.giftAmount}g",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// RETURN HOME BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainHomeScreen(),
                            ),
                            (_) => false,
                          );
                        },
                        child: Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                Color(0xFF675A3D),
                                Color(0xFFBBA473),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Return to home",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  /// SUMMARY ROW
  Widget _summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey.shade800,
      height: 20,
    );
  }
}
