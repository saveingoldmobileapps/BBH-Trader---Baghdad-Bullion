import 'package:baghdad_bullion_house/core/theme/app_fonts.dart';
import 'package:baghdad_bullion_house/presentation/screens/auth_screens/al_taif_bank_kyc/before_we_begin_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F0E2),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogoHeader(),
                    // const SizedBox(height: 14),
                    // BAGHDAD BULLION HOUSE Header
                    _buildHeader(),
                    const SizedBox(height: 24),
                    // Arabic texts
                    _buildArabicText(),
                    // const Divider(height: 40, thickness: 1.5,),
                    Center(
                      child: SizedBox(
                        width: 100, // control the length here
                        child: Divider(
                          height: 40,
                          thickness: 1.5,
                          color: Color(0xFFC49A2A),
                        ),
                      ),
                    ),
                    // Bank name
                    _buildBankInfo(),
                    const SizedBox(height: 16),
                    Center(
                      child: SizedBox(
                        width: 200, // control the length here
                        child: Divider(
                          height: 40,
                          thickness: 1.5,
                          color: Color(0xFFC49A2A),
                        ),
                      ),
                    ),
                    // Document info
                    //_buildDocumentInfo(),
                    // const SizedBox(height: 32),
                    // Table grid
                    _buildInfoGrid(),
                    const SizedBox(height: 40),
                    // Begin Onboarding Button
                    _buildOnboardingButton(context),
                    const SizedBox(height: 15),
                    const Center(
                      child: Text(
                        'Tap to start. Approx. 6 minutes.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF666666),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Container(
      height: 200,
      width: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: const DecorationImage(
          image: AssetImage(
            "assets/png/app_ic.png",
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BAGHDAD',
          style: TextStyle(
            fontFamily: 'DINNextArabic',
            fontWeight: FontWeight.w300, // Bold
            fontSize: 32,
            letterSpacing: 1.5,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          'BULLION',
          style: TextStyle(
            fontFamily: AppFonts.bbhFontFamily, //'DINNextArabic',
            //fontWeight: FontWeight.w400,  // Light
            fontSize: 28,
            letterSpacing: 1.2,
            color: Color(0xFF1A1A1A),
          ),
        ),
        Text(
          'HOUSE',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildArabicText() {
    return const Text(
      'دار بغداد لصياغة الذهب و الفضة والسبائك الذهبية',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF666666),
        height: 1.5,
      ),
      textAlign: TextAlign.end,
    );
  }

  Widget _buildBankInfo() {
    return const Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Al-Taif Islamic Bank',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Client Onboarding',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Document 001 of the BBH Bank Partnership Series',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
            // letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // Widget _buildDocumentInfo() {
  //   return  Text(
  //     'Document 001 of the BBH Bank Partnership Series',
  //     style: TextStyle(
  //       fontSize: 10,
  //       fontWeight: FontWeight.w600,
  //       color: Color(0xFF666666),
  //       // letterSpacing: 0.3,
  //     ),
  //   );
  // }

  // Widget _buildInfoGrid() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Text('Refrence',
  //     style: TextStyle(
  //       fontSize: 10,
  //       fontWeight: FontWeight.w600,
  //       color: Color(0xFF666666),
  //       // letterSpacing: 0.3,
  //     ),
  //   ),
  //   Text('Version',
  //     style: TextStyle(
  //       fontSize: 10,
  //       fontWeight: FontWeight.w600,
  //       color: Color(0xFF666666),
  //       // letterSpacing: 0.3,
  //     ),
  //   ),
  //         ],
  //       ),
  //      // const Divider(height: 40, thickness: 1.5,),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Text('BBH Bank 001',
  //     style: TextStyle(
  //       fontSize: 10,
  //       fontWeight: FontWeight.w600,
  //       color: Color(0xFF666666),
  //       // letterSpacing: 0.3,
  //     ),
  //   ),
  //   Text('1.0.Digital',
  //     style: TextStyle(
  //       fontSize: 10,
  //       fontWeight: FontWeight.w600,
  //       color: Color(0xFF666666),
  //       // letterSpacing: 0.3,
  //     ),
  //   ),
  //         ],
  //       )
  //     ],
  //   );
  //   // Define grid data

  // }
  Widget _buildInfoGrid() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First row - Labels
        Row(
          children: [
            Expanded(
              child: Text(
                'REFERENCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC49A2A),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'VERSION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC49A2A),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Second row - Values
        Row(
          children: [
            Expanded(
              child: Text(
                'BBH-BNK-001',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '1.0 · Digital',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        // Third row - Labels
        Row(
          children: [
            Expanded(
              child: Text(
                'CLASSIFICATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC49A2A),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'ISSUED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFC49A2A),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        // Fourth row - Values
        Row(
          children: [
            Expanded(
              child: Text(
                'Restricted',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '30 Apr 2026',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOnboardingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BBHOnboardingScreen(),
            ),
          );

          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Onboarding process started successfully'),
          //     backgroundColor: Color(0xFFC49A2A),
          //     behavior: SnackBarBehavior.floating,
          //     duration: Duration(seconds: 2),
          //   ),
          // );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF16243C),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'BEGIN ONBOARDING',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class GridItem {
  final String label;
  final String value;

  const GridItem({required this.label, required this.value});
}
