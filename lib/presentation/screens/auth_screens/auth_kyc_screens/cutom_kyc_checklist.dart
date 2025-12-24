import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/auth_kyc_screens/reupload_documets.dart'
    show ReUploadScreen;

import '../../../../core/res_sizes/res.dart';
import '../../../../core/theme/const_colors.dart';
import '../../../../core/theme/get_generic_text_widget.dart';
import '../../../sharedProviders/providers/home_provider.dart';
import '../../../widgets/button_widget.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  Widget _buildProfileTile(String title, String? value) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
      ),
      subtitle: Text(
        value ?? "-",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCheckTile(String title, bool? isMatched) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
      ),
      trailing: Icon(
        isMatched == true ? Icons.check_circle : Icons.cancel,
        color: isMatched == true ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile =
        ref.watch(homeProvider).getUserProfileResponse.payload?.userProfile;

    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final kyc = profile.userCustomKYCData;

    return Scaffold(
      backgroundColor: AppColors.greyScale1000,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.greyScale1000,
        elevation: 0,
        surfaceTintColor: AppColors.greyScale1000,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: GetGenericText(
          text: "Kyc Check List",
          fontSize: sizes!.responsiveFont(
            phoneVal: 20,
            tabletVal: 24,
          ),
          fontWeight: FontWeight.w400,
          color: AppColors.grey6Color,
          isInter: true,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greyScale900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: profile.imageUrl != null
                        ? NetworkImage(profile.imageUrl!)
                        : null,
                    child: profile.imageUrl == null
                        ? const Icon(Icons.person,
                            size: 40, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${profile.firstName ?? ""} ${profile.surname ?? ""}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Basic Info
            Card(
              color: AppColors.greyScale900,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildProfileTile("Email", profile.email),
                  _buildProfileTile("Phone", profile.phoneNumber),
                  _buildProfileTile("Date of Birth", profile.dateOfBirthday),
                  _buildProfileTile("Country", profile.countryOfResidence!.en??""),
                  _buildProfileTile("Nationality", profile.nationality!.en??""),
                  _buildProfileTile("Language", profile.language),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // KYC Checks
            if (kyc != null)
              Card(
                color: AppColors.greyScale900,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "KYC Verification",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    _buildCheckTile("First Name Match", kyc.isFirstNameMatched),
                    _buildCheckTile("Surname Match", kyc.isSurNameMatched),
                    _buildCheckTile("Date of Birth Match", kyc.isDOBMatched),
                    _buildCheckTile( "Nationality Match", kyc.isNationalityMatched),
                    _buildCheckTile("Residency Match", kyc.isResidencyMatched),
                    _buildCheckTile("Documents Valid", kyc.isDocumentsValid),
                    _buildCheckTile("Selfie Match", kyc.isUserImageMatched),
                    ListTile(
                      dense: true,
                      title: const Text("Admin Remarks",
                          style: TextStyle(color: Colors.white70)),
                      subtitle: Text(kyc.adminRemarks ?? "-",
                          style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ButtonWidget(
                        title: "ReUpload",
                        isLoadingState: false,
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReUploadScreen()));
                        },
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
