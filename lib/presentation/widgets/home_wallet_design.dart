import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:baghdad_bullion_house/core/core_export.dart';

class HomeFeedWalletV2 extends StatelessWidget {
  final bool isHiddenBalance;
  final dynamic walletExists; // Changed to dynamic to handle various types
  final VoidCallback onBalancePress;
  final VoidCallback onDepositPress;
  final VoidCallback onWithdrawPress;
  final double? balance;

  const HomeFeedWalletV2({
    super.key,
    required this.isHiddenBalance,
    required this.walletExists,
    required this.onBalancePress,
    required this.onDepositPress,
    required this.onWithdrawPress,
    this.balance,
  });

  // Helper method to convert walletExists to bool
  bool get _walletExistsValue {
    if (walletExists is bool) return walletExists;
    if (walletExists is int) return walletExists == 1;
    if (walletExists is String) return walletExists.toLowerCase() == 'true';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: screenHeight * 0.01,
        horizontal: screenWidth * 0.02,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF0D0D0D),
            const Color(0xFF1A1A1A),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
        border: Border.all(
          color: AppColors.goldLightColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.goldLightColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: SvgPicture.asset(
                  "assets/svg/gold_pattern.svg",
                  fit: BoxFit.cover,
                  placeholderBuilder: (context) => Container(), // Fallback if SVG doesn't exist
                ),
              ),
            ),
            
            // Top Right Gold Accent
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: isTablet ? 150 : 100,
                height: isTablet ? 150 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldLightColor.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Bottom Left Gold Accent
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: isTablet ? 120 : 80,
                height: isTablet ? 120 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.goldLightColor.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(isTablet ? 28 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(context, isTablet),
                  
                  SizedBox(height: screenHeight * 0.02),
                  
                  // Balance Section
                  _buildBalanceSection(context, isTablet, screenHeight),
                  
                  SizedBox(height: screenHeight * 0.025),
                  
                  // Action Buttons
                  _buildActionButtons(context, isTablet, screenWidth),
                  
                  // Additional Info
                  if (_walletExistsValue) ...[
                    SizedBox(height: screenHeight * 0.015),
                    _buildAdditionalInfo(context, isTablet),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 10 : 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.goldLightColor.withOpacity(0.2),
                    AppColors.goldDarkColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                border: Border.all(
                  color: AppColors.goldLightColor.withOpacity(0.3),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.primaryGold500,
                size: isTablet ? 28 : 22,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Text(
              "My Portfolio",
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        
        // Live Indicator
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 12 : 10,
            vertical: isTablet ? 6 : 4,
          ),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                "Live",
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSection(BuildContext context, bool isTablet, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Balance",
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: screenHeight * 0.008),
        GestureDetector(
          onTap: onBalancePress,
          child: Row(
            children: [
              if (_walletExistsValue) ...[
                isHiddenBalance
                    ? Row(
                        children: List.generate(
                          8,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 4),
                            width: isTablet ? 12 : 10,
                            height: isTablet ? 20 : 16,
                            color: AppColors.goldLightColor,
                          ),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\$",
                              style: TextStyle(
                                fontSize: isTablet ? 28 : 22,
                                fontWeight: FontWeight.w600,
                                color: AppColors.goldLightColor,
                                fontFamily: 'Monospace',
                              ),
                            ),
                            TextSpan(
                              text: balance?.toStringAsFixed(2) ?? "0.00",
                              style: TextStyle(
                                fontSize: isTablet ? 42 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                                fontFamily: 'Monospace',
                              ),
                            ),
                            TextSpan(
                              text: " USD",
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                SizedBox(width: 8),
                Icon(
                  isHiddenBalance ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white54,
                  size: isTablet ? 22 : 18,
                ),
              ] else ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No Wallet Found",
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Create a wallet to get started",
                      style: TextStyle(
                        fontSize: isTablet ? 12 : 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isTablet, double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.arrow_downward,
            label: "Deposit",
            onTap: onDepositPress,
            isTablet: isTablet,
            gradient: LinearGradient(
              colors: [
                AppColors.goldLightColor,
                AppColors.goldDarkColor,
              ],
            ),
            textColor: Colors.black,
          ),
        ),
        SizedBox(width: screenWidth * 0.04),
        Expanded(
          child: _buildActionButton(
            context: context,
            icon: Icons.arrow_upward,
            label: "Withdraw",
            onTap: onWithdrawPress,
            isTablet: isTablet,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2A2A2A),
                const Color(0xFF1A1A1A),
              ],
            ),
            textColor: AppColors.goldLightColor,
            borderColor: AppColors.goldLightColor.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isTablet,
    required LinearGradient gradient,
    required Color textColor,
    Color? borderColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 14,
          horizontal: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 1.2)
              : null,
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: textColor,
              size: isTablet ? 22 : 18,
            ),
            SizedBox(width: isTablet ? 12 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoItem(
            icon: Icons.trending_up,
            label: "24h Change",
            value: "+2.45%",
            valueColor: Colors.green,
            isTablet: isTablet,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.1),
          ),
          _buildInfoItem(
            icon: Icons.account_balance_wallet,
            label: "Active Orders",
            value: "3",
            valueColor: AppColors.goldLightColor,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required bool isTablet,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTablet ? 18 : 14,
          color: Colors.white54,
        ),
        SizedBox(width: isTablet ? 8 : 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 11 : 10,
                color: Colors.white54,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}