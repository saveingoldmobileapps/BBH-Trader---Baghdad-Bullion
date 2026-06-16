import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_otp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bbh_onboarding_controller.dart';
import 'bbh_onboarding_form.dart';
import 'bbh_onboarding_steps.dart';
import 'bbh_onboarding_theme.dart';
import 'bbh_onboarding_widgets.dart';

/// Review-step edit bottom sheet — matches HTML `editSheet` / `EDIT_SPECS`.
class BbhOnboardingEditSheet {
  BbhOnboardingEditSheet._();

  static const _captureOnly = {'biometrics', 'custodian'};

  static Future<void> open({
    required BuildContext context,
    required String sectionKey,
    required BbhOnboardingController controller,
    required VoidCallback onChanged,
    required Future<void> Function(TextEditingController, String) pickDate,
    required Future<void> Function(BbhOnboardingOtpChannel channel) onVerify,
  }) async {
    final form = controller.form;

    if (_captureOnly.contains(sectionKey)) {
      controller.goTo(
        sectionKey == 'biometrics'
            ? BbhOnboardingStep.documents
            : BbhOnboardingStep.custodian,
      );
      return;
    }

    if (sectionKey == 'passport' && form.noPassport) {
      controller.goTo(BbhOnboardingStep.documents);
      return;
    }

    final title = _titleFor(sectionKey);
    if (title == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            expand: false,
            builder: (_, scrollController) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  color: BbhOnboardingColors.cream,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x331C2638),
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: BbhOnboardingColors.rule,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 16, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: BbhOnboardingText.display(
                                size: 22,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close, size: 22),
                            color: BbhOnboardingColors.muted,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
                        child: _buildFields(
                          sectionKey: sectionKey,
                          form: form,
                          onChanged: onChanged,
                          pickDate: pickDate,
                          onVerify: onVerify,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 22),
                      child: BbhGoldButton(
                        label: 'Done',
                        onPressed: () async {
                          await controller.persist();
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                          onChanged();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static String? _titleFor(String key) => switch (key) {
        'contact' => 'Contact',
        'name' => 'Full Name',
        'personal' => 'Personal Details',
        'natid' => 'National ID',
        'passport' => 'Passport',
        'income' => 'Income & Employment',
        'address' => 'Address',
        'compliance' => 'Compliance',
        'foreignres' => 'Foreign Residency',
        'foreigncit' => 'Foreign Citizenship',
        _ => null,
      };

  static Widget _buildFields({
    required String sectionKey,
    required BbhOnboardingForm form,
    required VoidCallback onChanged,
    required Future<void> Function(TextEditingController, String) pickDate,
    required Future<void> Function(BbhOnboardingOtpChannel channel) onVerify,
  }) {
    return switch (sectionKey) {
      'contact' => _contactFields(form, onChanged, onVerify),
      'name' => _nameFields(form, pickDate),
      'personal' => _personalFields(form, onChanged, pickDate),
      'natid' => _natIdFields(form, pickDate),
      'passport' => _passportFields(form, pickDate),
      'income' => _incomeFields(form, onChanged),
      'address' => _addressFields(form, onChanged),
      'compliance' => _complianceFields(form, onChanged),
      'foreignres' => _foreignResFields(form, onChanged),
      'foreigncit' => _foreignCitFields(form, onChanged),
      _ => const SizedBox.shrink(),
    };
  }

  static Widget _groupLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: BbhOnboardingText.display(size: 17, weight: FontWeight.w600),
      ),
    );
  }

  static Widget _grid2(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  static Widget _contactFields(
    BbhOnboardingForm form,
    VoidCallback onChanged,
    Future<void> Function(BbhOnboardingOtpChannel) onVerify,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhTextField(
          controller: form.mobile,
          label: 'Mobile Number',
          hint: '+964 7XX XXX XXXX',
          keyboardType: TextInputType.phone,
          verified: form.verifiedMobile.value,
          onChanged: (_) {
            if (form.verifiedMobile.value) form.verifiedMobile.value = false;
            onChanged();
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 148,
            child: BbhGhostButton(
              label: form.verifiedMobile.value ? 'Verified ✓' : 'Verify Number',
              onPressed: form.verifiedMobile.value
                  ? null
                  : () => onVerify(BbhOnboardingOtpChannel.mobile),
            ),
          ),
        ),
        const SizedBox(height: 12),
        BbhTextField(
          controller: form.email,
          label: 'Email Address',
          hint: 'client@example.com',
          keyboardType: TextInputType.emailAddress,
          verified: form.verifiedEmail.value,
          capitalization: TextCapitalization.none,
          onChanged: (_) {
            if (form.verifiedEmail.value) form.verifiedEmail.value = false;
            onChanged();
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 148,
            child: BbhGhostButton(
              label: form.verifiedEmail.value ? 'Verified ✓' : 'Verify Email',
              onPressed: form.verifiedEmail.value || !form.verifiedMobile.value
                  ? null
                  : () => onVerify(BbhOnboardingOtpChannel.email),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const BbhInfoBanner(
          text:
              'A changed number or email must be verified again before you can submit.',
        ),
      ],
    );
  }

  static Widget _nameFields(
    BbhOnboardingForm form,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _groupLabel('In Arabic'),
        _grid2(
          BbhTextField(
            controller: form.arFirst,
            label: 'First Name',
            verified: form.isVerified('ar_first'),
            textDirection: TextDirection.rtl,
          ),
          BbhTextField(
            controller: form.arFather,
            label: "Father's Name",
            verified: form.isVerified('ar_father'),
            textDirection: TextDirection.rtl,
          ),
        ),
        _grid2(
          BbhTextField(
            controller: form.arGf,
            label: "Grandfather's",
            verified: form.isVerified('ar_gf'),
            textDirection: TextDirection.rtl,
          ),
          BbhTextField(
            controller: form.arSurname,
            label: 'Surname',
            verified: form.isVerified('ar_surname'),
            textDirection: TextDirection.rtl,
          ),
        ),
        BbhTextField(
          controller: form.arMother,
          label: "Mother's Name",
          verified: form.isVerified('ar_mother'),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 12),
        _groupLabel('In English'),
        _grid2(
          BbhTextField(
            controller: form.enFirst,
            label: 'First Name',
            verified: form.isVerified('en_first'),
            capitalization: TextCapitalization.words,
          ),
          BbhTextField(
            controller: form.enFather,
            label: "Father's Name",
            verified: form.isVerified('en_father'),
            capitalization: TextCapitalization.words,
          ),
        ),
        _grid2(
          BbhTextField(
            controller: form.enGf,
            label: "Grandfather's",
            verified: form.isVerified('en_gf'),
            capitalization: TextCapitalization.words,
          ),
          BbhTextField(
            controller: form.enSurname,
            label: 'Surname',
            verified: form.isVerified('en_surname'),
            capitalization: TextCapitalization.words,
          ),
        ),
        BbhTextField(
          controller: form.enMother,
          label: "Mother's Name",
          verified: form.isVerified('en_mother'),
          capitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  static Widget _personalFields(
    BbhOnboardingForm form,
    VoidCallback onChanged,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhToggleGroup(
          label: 'Gender',
          value: form.gender,
          options: const ['Male', 'Female'],
          onChanged: (v) {
            form.gender = v;
            onChanged();
          },
        ),
        const SizedBox(height: 12),
        BbhTextField(
          controller: form.nationality,
          label: 'Nationality',
          verified: form.isVerified('nationality'),
        ),
        _grid2(
          BbhTextField(
            controller: form.dob,
            label: 'Date of Birth',
            readOnly: true,
            verified: form.isVerified('dob'),
            onTap: () => pickDate(form.dob, 'dob'),
          ),
          BbhTextField(
            controller: form.countryBirth,
            label: 'Country of Birth',
            verified: form.isVerified('country_birth'),
          ),
        ),
        BbhTextField(
          controller: form.placeBirth,
          label: 'Place of Birth',
          verified: form.isVerified('place_birth'),
        ),
      ],
    );
  }

  static Widget _natIdFields(
    BbhOnboardingForm form,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _grid2(
          BbhTextField(
            controller: form.idPersonal,
            label: 'Personal Number',
            verified: form.isVerified('id_personal'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
          ),
          BbhTextField(
            controller: form.idSerial,
            label: 'ID Number (Card Serial)',
            verified: form.isVerified('id_serial'),
            capitalization: TextCapitalization.characters,
          ),
        ),
        BbhTextField(
          controller: form.idIssuePlace,
          label: 'Place of Issue',
          verified: form.isVerified('id_issue_place'),
        ),
        _grid2(
          BbhTextField(
            controller: form.idIssueDate,
            label: 'Date of Issue',
            readOnly: true,
            verified: form.isVerified('id_issue_date'),
            onTap: () => pickDate(form.idIssueDate, 'id_issue_date'),
          ),
          BbhTextField(
            controller: form.idExpiryDate,
            label: 'Date of Expiry',
            readOnly: true,
            verified: form.isVerified('id_expiry_date'),
            onTap: () => pickDate(form.idExpiryDate, 'id_expiry_date'),
          ),
        ),
      ],
    );
  }

  static Widget _passportFields(
    BbhOnboardingForm form,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _grid2(
          BbhTextField(
            controller: form.ppNo,
            label: 'Passport Number',
            verified: form.isVerified('pp_no'),
          ),
          BbhTextField(
            controller: form.ppPlace,
            label: 'Place of Issue',
            verified: form.isVerified('pp_place'),
          ),
        ),
        _grid2(
          BbhTextField(
            controller: form.ppIssue,
            label: 'Date of Issue',
            readOnly: true,
            verified: form.isVerified('pp_issue'),
            onTap: () => pickDate(form.ppIssue, 'pp_issue'),
          ),
          BbhTextField(
            controller: form.ppExpiry,
            label: 'Date of Expiry',
            readOnly: true,
            verified: form.isVerified('pp_expiry'),
            onTap: () => pickDate(form.ppExpiry, 'pp_expiry'),
          ),
        ),
      ],
    );
  }

  static Widget _incomeFields(BbhOnboardingForm form, VoidCallback onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhOnboardingSteps.editDropdown(
          'Education Level',
          form.education,
          BbhOnboardingSteps.educationLevels,
          (v) {
            form.education = v;
            onChanged();
          },
        ),
        BbhOnboardingSteps.editDropdown(
          'Economic Sector',
          form.sector,
          BbhOnboardingSteps.sectors,
          (v) {
            form.sector = v;
            onChanged();
          },
        ),
        BbhTextField(
          controller: form.income,
          label: 'Total Monthly Income (IQD)',
          keyboardType: TextInputType.number,
        ),
        BbhTextField(controller: form.occupation, label: 'Occupation'),
        BbhTextField(controller: form.employer, label: 'Employer Name'),
        BbhTextField(
          controller: form.employerAddr,
          label: 'Employer Address',
          maxLines: 3,
        ),
      ],
    );
  }

  static Widget _addressFields(BbhOnboardingForm form, VoidCallback onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhOnboardingSteps.editDropdown(
          'Governorate',
          form.addrGov.text.isEmpty ? null : form.addrGov.text,
          BbhOnboardingSteps.governorates,
          (v) {
            form.addrGov.text = v ?? '';
            onChanged();
          },
        ),
        BbhTextField(controller: form.addrDistrict, label: 'District'),
        BbhTextField(controller: form.addrCity, label: 'City / Town'),
        BbhTextField(controller: form.addrMahalla, label: 'Mahalla'),
        BbhTextField(controller: form.addrStreet, label: 'Street'),
        BbhTextField(controller: form.addrHouse, label: 'House No.'),
        BbhTextField(
          controller: form.addrLandmarkAr,
          label: 'Nearest Landmark (Arabic)',
          textDirection: TextDirection.rtl,
        ),
        BbhTextField(
          controller: form.addrLandmarkEn,
          label: 'Nearest Landmark (English)',
        ),
      ],
    );
  }

  static Widget _complianceFields(
    BbhOnboardingForm form,
    VoidCallback onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhToggleGroup(
          label: 'Are you a U.S. person?',
          value: form.fatca,
          options: const ['No', 'Yes'],
          onChanged: (v) {
            form.fatca = v;
            onChanged();
          },
        ),
        if (form.fatca == 'Yes') ...[
          BbhTextField(controller: form.fatcaTin, label: 'U.S. TIN / SSN'),
          BbhTextField(
            controller: form.fatcaAddr,
            label: 'U.S. Address',
            maxLines: 3,
          ),
        ],
        const SizedBox(height: 16),
        BbhToggleGroup(
          label: 'Do you fall into any PEP category?',
          value: form.pep,
          options: const ['No', 'Yes'],
          onChanged: (v) {
            form.pep = v;
            onChanged();
          },
        ),
        if (form.pep == 'Yes') ...[
          BbhTextField(
            controller: form.pepPosition,
            label: 'Position Held / Relationship to PEP',
          ),
          BbhTextField(controller: form.pepCountry, label: 'Country'),
          _grid2(
            BbhTextField(
              controller: form.pepFrom,
              label: 'From (MM/YYYY)',
              hint: 'MM/YYYY',
            ),
            BbhTextField(
              controller: form.pepTo,
              label: 'To (MM/YYYY)',
              hint: 'MM/YYYY',
            ),
          ),
        ],
      ],
    );
  }

  static Widget _foreignResFields(
    BbhOnboardingForm form,
    VoidCallback onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhToggleGroup(
          label: 'Permission to reside outside Iraq?',
          value: form.foreignRes,
          options: const ['No', 'Yes'],
          onChanged: (v) {
            form.foreignRes = v;
            onChanged();
          },
        ),
        if (form.foreignRes == 'Yes')
          BbhTextField(
            controller: form.foreignResCountry,
            label: 'Country',
          ),
      ],
    );
  }

  static Widget _foreignCitFields(
    BbhOnboardingForm form,
    VoidCallback onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BbhToggleGroup(
          label: 'Citizenship in another country?',
          value: form.foreignCit,
          options: const ['No', 'Yes'],
          onChanged: (v) {
            form.foreignCit = v;
            onChanged();
          },
        ),
        if (form.foreignCit == 'Yes')
          BbhTextField(
            controller: form.foreignCitCountry,
            label: 'Country',
          ),
      ],
    );
  }
}
