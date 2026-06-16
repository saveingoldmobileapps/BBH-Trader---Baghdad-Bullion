import 'package:baghdad_bullion_house/services/bbh_onboarding/bbh_onboarding_otp_service.dart';
import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'bbh_onboarding_field_scroll.dart';
import 'bbh_onboarding_form.dart';
import 'bbh_onboarding_theme.dart';
import 'bbh_onboarding_widgets.dart';

/// Builds native Flutter content for each onboarding step.
class BbhOnboardingSteps {
  BbhOnboardingSteps._();

  static const educationLevels = [
    'Postgraduate',
    'University',
    'Diploma',
    'Preparatory',
    'Intermediate',
    'Primary',
  ];

  static const sectors = [
    'Commercial / Trade',
    'Services',
    'Private sector',
    'Government',
    'Undefined',
  ];

  static const governorates = [
    'Baghdad',
    'Basra',
    'Nineveh',
    'Erbil',
    'Najaf',
    'Karbala',
    'Anbar',
    'Dhi Qar',
    'Babil',
    'Diyala',
    'Kirkuk',
    'Saladin',
    'Wasit',
    'Maysan',
    'Muthanna',
    'Qadisiyyah',
    'Sulaymaniyah',
    'Duhok',
    'Halabja',
  ];

  static Widget cover({
    required VoidCallback onBegin,
    required VoidCallback onExit,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                BbhOnboardingColors.coverDarkTop,
                BbhOnboardingColors.coverDarkMid,
                BbhOnboardingColors.coverDarkBottom,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      Image.asset(
                        'assets/png/app_ic.png',
                        height: 132,
                        width: 132,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Baghdad\nBullion House',
                        textAlign: TextAlign.center,
                        style: BbhOnboardingText.display(
                          size: 38,
                          weight: FontWeight.w600,
                          color: const Color(0xFFF0E2BD),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'دار بغداد لصياغة الذهب و الفضة والسبائك الذهبية',
                        textAlign: TextAlign.center,
                        style: BbhOnboardingText.arabic(
                          size: 18,
                          color: const Color(0xD9E8D49E),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 90,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              BbhOnboardingColors.goldLight.withValues(
                                alpha: 0.85,
                              ),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: BbhOnboardingColors.gold.withValues(
                                alpha: 0.28,
                              ),
                            ),
                            bottom: BorderSide(
                              color: BbhOnboardingColors.gold.withValues(
                                alpha: 0.28,
                              ),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'CLASSIFICATION',
                              style: BbhOnboardingText.manrope(
                                size: 9,
                                weight: FontWeight.w600,
                                letterSpacing: 2.2,
                                color: BbhOnboardingColors.goldLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Restricted',
                              style: BbhOnboardingText.display(
                                size: 15,
                                weight: FontWeight.w500,
                                color: const Color(0xFFF0E2BD),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 2),
                      BbhGoldButton(
                        label: 'Begin Onboarding',
                        onPressed: onBegin,
                        forCover: true,
                      ),
                      const SizedBox(height: 10),
                      BbhGhostButton(
                        label: 'Exit',
                        onPressed: onExit,
                        onDark: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget preflight() {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Before you begin',
        title: 'Have these documents ready',
        lede:
            'All three documents below are required to complete onboarding. Please have them with you before continuing.',
      ),
      const SizedBox(height: 20),
      _preflightItem(
        icon: '🪪',
        title: 'National Identity Card',
        subtitle: 'Front and back. Both card numbers will be required.',
      ),
      _preflightItem(
        icon: '🏠',
        title: 'Residence Card',
        subtitle: 'Front and back.',
      ),
      _preflightItem(
        icon: '📕',
        title: 'Passport (if you have one)',
        subtitle: 'Used for your name in English. You can continue without it.',
      ),
      const SizedBox(height: 8),
      const BbhPreflightNote(
        lead: "You'll also need:",
        body: 'roughly six (6) minutes to complete the form.',
      ),
      const SizedBox(height: 12),
      Text(
        'Additional documents may be required if you hold residency or citizenship outside Iraq.',
        textAlign: TextAlign.center,
        style: BbhOnboardingText.manrope(
          size: 12.5,
          color: BbhOnboardingColors.muted,
          height: 1.6,
        ).copyWith(fontStyle: FontStyle.italic),
      ),
    ]);
  }

  static Widget purpose(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Section 1 · Purpose & Scope',
        title: 'Before we begin',
      ),
      const SizedBox(height: 20),
      const BbhClauseItem(
        number: '1.1',
        bold: 'About Baghdad Bullion House.',
        body:
            'BBH is a licensed dealer in precious metals and stones, registered in Iraq under Commercial Registration No. 17240, with four (4) branches in Baghdad and one (1) in Najaf.',
      ),
      const BbhClauseItem(
        number: '1.2',
        bold: 'What we collect.',
        body:
            'This onboarding captures your identifying details, economic profile, and compliance declarations to open your gold account with BBH.',
      ),
      const BbhClauseItem(
        number: '1.3',
        bold: 'What we keep.',
        body:
            'All records are held securely by BBH for the period required by Iraqi law, not less than seven (7) years from the closure of the account or last transaction.',
      ),
      const SizedBox(height: 8),
      BbhConfirmRow(
        fieldKey: 'purpose_confirmed',
        text:
            'I have been informed of the above and wish to proceed with BBH onboarding.',
        checked: form.purposeConfirmed,
        onChanged: (_) {
          form.purposeConfirmed = !form.purposeConfirmed;
          onChanged();
        },
      ),
    ]);
  }

  static Widget documents({
    required BbhOnboardingForm form,
    required VoidCallback onChanged,
    required Future<void> Function(IpassScanTarget target) onIpassCapture,
    required IpassScanTarget? ipassLoadingTarget,
  }) {
    final idCaptured = form.idFrontCaptured && form.idBackCaptured;
    final resCaptured = form.resFrontCaptured && form.resBackCaptured;

    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 1 · Document Capture',
        title: 'Let’s start with your documents',
        lede:
            'Capture each document clearly. We’ll read your details automatically and you can review them on the next screen.',
      ),
      const SizedBox(height: 20),
      BbhDocCaptureRow(
        badge: '1',
        title: 'Identity Verification',
        captured: idCaptured,
        loading:
            ipassLoadingTarget == IpassScanTarget.nationalId && !idCaptured,
        onCapture: () => onIpassCapture(IpassScanTarget.nationalId),
        onReplace: idCaptured
            ? () => onIpassCapture(IpassScanTarget.nationalId)
            : null,
      ),
      BbhDocCaptureRow(
        badge: '2',
        title: 'Residence Card (Front and Back)',
        captured: resCaptured,
        loading:
            ipassLoadingTarget == IpassScanTarget.residence && !resCaptured,
        onCapture: () => onIpassCapture(IpassScanTarget.residence),
        onReplace: resCaptured
            ? () async {
                form.resFrontCaptured = false;
                form.resBackCaptured = false;
                onChanged();
                await onIpassCapture(IpassScanTarget.residence);
              }
            : null,
      ),
      if (!form.noPassport) ...[
        BbhDocCaptureRow(
          badge: '3',
          title: 'Passport — Photo Page',
          captured: form.passportCaptured,
          loading:
              ipassLoadingTarget == IpassScanTarget.passport &&
              !form.passportCaptured,
          onCapture: () => onIpassCapture(IpassScanTarget.passport),
          onReplace: form.passportCaptured
              ? () async {
                  form.passportCaptured = false;
                  onChanged();
                  await onIpassCapture(IpassScanTarget.passport);
                }
              : null,
        ),
        BbhDocSkipLink(
          label: "I don't have a passport",
          onTap: () {
            form.noPassport = true;
            form.passportCaptured = false;
            form.ppNo.clear();
            form.ppPlace.clear();
            form.ppIssue.clear();
            form.ppExpiry.clear();
            onChanged();
          },
        ),
      ] else
        BbhDocSkippedRow(
          title: 'Passport — not provided',
          note: 'Your English name will be entered manually.',
          onUndo: () {
            form.noPassport = false;
            onChanged();
          },
        ),
    ]);
  }

  static Widget ocrReview(
    BbhOnboardingForm form,
    VoidCallback onChanged,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    final hasScan = form.idFrontCaptured;
    return _scroll([
      BbhStepHeader(
        eyebrow: 'Step 2 · Your Details',
        title: hasScan ? 'Check what we read' : 'Enter your details',
        lede: hasScan
            ? 'These details were read from your documents. Please check each field and correct anything that looks wrong before continuing.'
            : 'Please enter the following details exactly as they appear on your documents.',
      ),
      if (hasScan) const BbhInfoBanner(text: 'Auto-filled from your documents'),
      _groupTitle(
        'Full name in Arabic',
        'As written on the national identity card.',
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'ar_first',
          controller: form.arFirst,
          label: 'First Name',
          verified: form.isVerified('ar_first'),
          textDirection: TextDirection.rtl,
        ),
        BbhTextField(
          fieldKey: 'ar_father',
          controller: form.arFather,
          label: "Father's Name",
          verified: form.isVerified('ar_father'),
          textDirection: TextDirection.rtl,
        ),
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'ar_gf',
          controller: form.arGf,
          label: "Grandfather's",
          verified: form.isVerified('ar_gf'),
          textDirection: TextDirection.rtl,
        ),
        BbhTextField(
          fieldKey: 'ar_surname',
          controller: form.arSurname,
          label: 'Surname',
          verified: form.isVerified('ar_surname'),
          textDirection: TextDirection.rtl,
        ),
      ),
      BbhTextField(
        fieldKey: 'ar_mother',
        controller: form.arMother,
        label: "Mother's Name + Maternal Grandfather",
        verified: form.isVerified('ar_mother'),
        textDirection: TextDirection.rtl,
      ),
      const SizedBox(height: 24),
      _groupTitle(
        'Full name in English',
        form.noPassport
            ? 'Your full name in English (Latin letters).'
            : 'As it appears on the passport.',
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'en_first',
          controller: form.enFirst,
          label: 'First Name',
          verified: form.isVerified('en_first'),
          capitalization: TextCapitalization.words,
        ),
        BbhTextField(
          fieldKey: 'en_father',
          controller: form.enFather,
          label: "Father's Name",
          verified: form.isVerified('en_father'),
          capitalization: TextCapitalization.words,
        ),
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'en_gf',
          controller: form.enGf,
          label: "Grandfather's",
          verified: form.isVerified('en_gf'),
          capitalization: TextCapitalization.words,
        ),
        BbhTextField(
          fieldKey: 'en_surname',
          controller: form.enSurname,
          label: 'Surname',
          verified: form.isVerified('en_surname'),
          capitalization: TextCapitalization.words,
        ),
      ),
      BbhTextField(
        fieldKey: 'en_mother',
        controller: form.enMother,
        label: "Mother's Name + Maternal Grandfather",
        verified: form.isVerified('en_mother'),
        capitalization: TextCapitalization.words,
      ),
      const SizedBox(height: 24),
      _groupTitle(
        'National Identity Card',
        'Both numbers are printed on the same card.',
      ),
      _grid2(
        _fieldWithHint(
          BbhTextField(
            fieldKey: 'id_personal',
            controller: form.idPersonal,
            label: 'Personal Number',
            verified: form.isVerified('id_personal'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            hint: '123456789012',
          ),
          '12 digits. Same across renewals.',
        ),
        _fieldWithHint(
          BbhTextField(
            fieldKey: 'id_serial',
            controller: form.idSerial,
            label: 'ID Number (Card Serial)',
            verified: form.isVerified('id_serial'),
            capitalization: TextCapitalization.characters,
            hint: 'A12345678',
          ),
          'One letter + 8 digits. Changes on renewal.',
        ),
      ),
      BbhTextField(
        fieldKey: 'id_issue_place',
        controller: form.idIssuePlace,
        label: 'Place of Issue',
        verified: form.isVerified('id_issue_place'),
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'id_issue_date',
          controller: form.idIssueDate,
          label: 'Date of Issue',
          readOnly: true,
          verified: form.isVerified('id_issue_date'),
          onTap: () => pickDate(form.idIssueDate, 'id_issue_date'),
        ),
        BbhTextField(
          fieldKey: 'id_expiry_date',
          controller: form.idExpiryDate,
          label: 'Date of Expiry',
          readOnly: true,
          verified: form.isVerified('id_expiry_date'),
          onTap: () => pickDate(form.idExpiryDate, 'id_expiry_date'),
        ),
      ),
      if (!form.noPassport) ...[
        const SizedBox(height: 24),
        _groupTitle('Passport', null),
        _grid2(
          BbhTextField(
            fieldKey: 'pp_no',
            controller: form.ppNo,
            label: 'Passport Number',
            verified: form.isVerified('pp_no'),
          ),
          BbhTextField(
            fieldKey: 'pp_place',
            controller: form.ppPlace,
            label: 'Place of Issue',
            verified: form.isVerified('pp_place'),
          ),
        ),
        _grid2(
          BbhTextField(
            fieldKey: 'pp_issue',
            controller: form.ppIssue,
            label: 'Date of Issue',
            readOnly: true,
            verified: form.isVerified('pp_issue'),
            onTap: () => pickDate(form.ppIssue, 'pp_issue'),
          ),
          BbhTextField(
            fieldKey: 'pp_expiry',
            controller: form.ppExpiry,
            label: 'Date of Expiry',
            readOnly: true,
            verified: form.isVerified('pp_expiry'),
            onTap: () => pickDate(form.ppExpiry, 'pp_expiry'),
          ),
        ),
      ],
    ]);
  }

  static Widget residenceAddress(
    BbhOnboardingForm form,
    VoidCallback onChanged,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 3 · Residence & Address',
        title: 'Residence card & address',
        lede: 'Please enter these details from your residence card.',
      ),
      const SizedBox(height: 20),
      _groupTitle('Residence Card', null),
      BbhTextField(
        fieldKey: 'res_no',
        controller: form.resNo,
        label: 'Residence Card Number',
        verified: form.isVerified('res_no'),
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'res_place',
          controller: form.resPlace,
          label: 'Place of Issue',
          verified: form.isVerified('res_place'),
        ),
        BbhTextField(
          fieldKey: 'res_issue',
          controller: form.resIssue,
          label: 'Date of Issue',
          readOnly: true,
          verified: form.isVerified('res_issue'),
          onTap: () => pickDate(form.resIssue, 'res_issue'),
        ),
      ),
      const SizedBox(height: 24),
      _groupTitle('Address', null),
      _dropdown(
        'Governorate',
        form.addrGov.text.isEmpty ? null : form.addrGov.text,
        governorates,
        (v) {
          form.addrGov.text = v ?? '';
          onChanged();
        },
        fieldKey: 'addr_gov',
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'addr_district',
          controller: form.addrDistrict,
          label: 'District',
          verified: form.isVerified('addr_district'),
        ),
        BbhTextField(
          fieldKey: 'addr_city',
          controller: form.addrCity,
          label: 'City / Town',
          verified: form.isVerified('addr_city'),
        ),
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'addr_mahalla',
          controller: form.addrMahalla,
          label: 'Mahalla',
          verified: form.isVerified('addr_mahalla'),
        ),
        BbhTextField(
          fieldKey: 'addr_street',
          controller: form.addrStreet,
          label: 'Street',
          verified: form.isVerified('addr_street'),
        ),
      ),
      BbhTextField(
        fieldKey: 'addr_house',
        controller: form.addrHouse,
        label: 'House No.',
        verified: form.isVerified('addr_house'),
      ),
      BbhTextField(
        fieldKey: 'addr_landmark_ar',
        controller: form.addrLandmarkAr,
        label: 'Nearest Landmark (Arabic)',
        textDirection: TextDirection.rtl,
        verified: form.isVerified('addr_landmark_ar'),
      ),
      BbhTextField(
        controller: form.addrLandmarkEn,
        label: 'Nearest Landmark (English)',
        verified: form.isVerified('addr_landmark_en'),
      ),
      const SizedBox(height: 18),
      _groupTitle('Additional Residency', 'Outside Iraq.'),
      BbhToggleGroup(
        label: 'Do you have permission to reside outside Iraq?',
        value: form.foreignRes,
        options: const ['No', 'Yes'],
        onChanged: (v) {
          form.foreignRes = v;
          onChanged();
        },
      ),
      if (form.foreignRes == 'Yes')
        BbhTextField(
          fieldKey: 'foreign_res_country',
          controller: form.foreignResCountry,
          label: 'Country',
        ),
      const SizedBox(height: 18),
      _groupTitle('Additional Citizenship', 'Outside Iraq.'),
      BbhToggleGroup(
        label: 'Do you hold citizenship in another country?',
        value: form.foreignCit,
        options: const ['No', 'Yes'],
        onChanged: (v) {
          form.foreignCit = v;
          onChanged();
        },
      ),
      if (form.foreignCit == 'Yes')
        BbhTextField(
          fieldKey: 'foreign_cit_country',
          controller: form.foreignCitCountry,
          label: 'Country',
        ),
    ]);
  }

  static Widget personalDetails(
    BbhOnboardingForm form,
    VoidCallback onChanged,
    Future<void> Function(TextEditingController, String) pickDate,
  ) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 4 · Personal Details',
        title: 'A few personal details',
      ),
      const SizedBox(height: 20),
      BbhToggleGroup(
        fieldKey: 'gender',
        label: 'Gender',
        value: form.gender,
        options: const ['Male', 'Female'],
        onChanged: (v) {
          form.gender = v;
          onChanged();
        },
      ),
      const SizedBox(height: 16),
      BbhTextField(
        fieldKey: 'nationality',
        controller: form.nationality,
        label: 'Nationality',
        verified: form.isVerified('nationality'),
      ),
      _grid2(
        BbhTextField(
          fieldKey: 'dob',
          controller: form.dob,
          label: 'Date of Birth',
          readOnly: true,
          verified: form.isVerified('dob'),
          onTap: () => pickDate(form.dob, 'dob'),
        ),
        BbhTextField(
          fieldKey: 'country_birth',
          controller: form.countryBirth,
          label: 'Country of Birth',
          verified: form.isVerified('country_birth'),
        ),
      ),
      BbhTextField(
        fieldKey: 'place_birth',
        controller: form.placeBirth,
        label: 'Place of Birth',
        hint: 'City or town (max 20 chars)',
        inputFormatters: [LengthLimitingTextInputFormatter(20)],
        verified: form.isVerified('place_birth'),
      ),
    ]);
  }

  static Widget income(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 5 · Income & Employment',
        title: 'Source of income',
      ),
      const SizedBox(height: 20),
      _dropdown(
        'Education Level',
        form.education,
        educationLevels,
        (v) {
          form.education = v;
          onChanged();
        },
        fieldKey: 'education',
      ),
      const SizedBox(height: 12),
      _dropdown(
        'Economic Sector',
        form.sector,
        sectors,
        (v) {
          form.sector = v;
          onChanged();
        },
        fieldKey: 'sector',
      ),
      BbhTextField(
        fieldKey: 'income',
        controller: form.income,
        label: 'Total Monthly Income (IQD)',
        keyboardType: TextInputType.number,
        hint: 'e.g. 2,500,000',
      ),
      BbhTextField(
        fieldKey: 'occupation',
        controller: form.occupation,
        label: 'Occupation',
        hint: 'e.g. Goldsmith, Trader, Engineer',
      ),
      BbhTextField(
        fieldKey: 'employer',
        controller: form.employer,
        label: 'Employer Name',
        hint: 'Or "Retired", "Student", "Housewife", "Unemployed"',
      ),
      BbhTextField(
        fieldKey: 'employer_addr',
        controller: form.employerAddr,
        label: 'Employer Address',
        maxLines: 3,
      ),
    ]);
  }

  static Widget fatca(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 6 · FATCA Declaration',
        title: 'U.S. tax residency',
      ),
      const SizedBox(height: 16),
      BbhCallout(
        title: "Who is a U.S. person?",
        text:
            'A U.S. citizen, a U.S. green-card holder, or any other person treated as a U.S. tax resident.',
      ),
      // _calloutWithTitle(
      //   title: 'Who is a U.S. person?',
      //   paragraphs: const [
      //     'A U.S. citizen, a U.S. green-card holder, or any other person treated as a U.S. tax resident.',
      //   ],
      // ),
      const SizedBox(height: 16),
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
        BbhTextField(
          fieldKey: 'fatca_tin',
          controller: form.fatcaTin,
          label: 'U.S. TIN / SSN',
        ),
        BbhTextField(
          fieldKey: 'fatca_addr',
          controller: form.fatcaAddr,
          label: 'U.S. Address',
          maxLines: 3,
        ),
      ],
    ]);
  }

  static Widget pep(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 7 · PEP Declaration',
        title: 'Politically Exposed Person',
      ),
      const SizedBox(height: 16),
      BbhCallout(
        text:
            'A person who holds — or has held in the previous twelve months — a prominent public function: heads of state, ministers, members of parliament, senior judges, senior military or police officers, senior officials of state-owned enterprises, or senior officials of political parties.',
        title: "What counts as a PEP?",
      ),

      // _calloutWithTitle(
      //   title: 'What counts as a PEP?',
      //   paragraphs: const [
      //     'A person who holds — or has held in the previous twelve months — a prominent public function: heads of state, ministers, members of parliament, senior judges, senior military or police officers, senior officials of state-owned enterprises, or senior officials of political parties.',
      //     'This covers you, your close family members, and your known close associates.',
      //   ],
      // ),
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
          fieldKey: 'pep_position',
          controller: form.pepPosition,
          label: 'Position Held / Relationship to PEP',
        ),
        BbhTextField(
          fieldKey: 'pep_country',
          controller: form.pepCountry,
          label: 'Country',
        ),
        _grid2(
          BbhTextField(
            fieldKey: 'pep_from',
            controller: form.pepFrom,
            label: 'From (MM/YYYY)',
            hint: 'MM/YYYY',
          ),
          BbhTextField(
            fieldKey: 'pep_to',
            controller: form.pepTo,
            label: 'To (MM/YYYY)',
            hint: 'MM/YYYY',
          ),
        ),
      ],
    ]);
  }

  static Widget contact(
    BbhOnboardingForm form,
    VoidCallback onChanged, {
    required Future<void> Function(BbhOnboardingOtpChannel channel) onVerify,
  }) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 8 · Contact & Verification',
        title: 'Where can we reach you?',
      ),
      const SizedBox(height: 20),

      // Mobile First
      BbhTextField(
        fieldKey: 'mobile',
        controller: form.mobile,
        label: 'Mobile Number',
        hint: '+964 7XX XXX XXXX or 00964…',
        keyboardType: TextInputType.phone,
        verified: form.verifiedMobile.value,
        onChanged: (_) {
          if (form.verifiedMobile.value) {
            form.verifiedMobile.value = false;
          }
          onChanged();
        },
      ),
      const SizedBox(height: 6),
      Text(
        'International format: 00… or +…. Verified as 00… for the API.',
        style: BbhOnboardingText.manrope(
          size: 12,
          color: BbhOnboardingColors.muted,
        ),
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

      const SizedBox(height: 20),

      // Email Second
      BbhTextField(
        fieldKey: 'email',
        controller: form.email,
        label: 'Email Address',
        hint: 'client@example.com',
        keyboardType: TextInputType.emailAddress,
        verified: form.verifiedEmail.value,
        capitalization: TextCapitalization.none,
        onChanged: (_) {
          if (form.verifiedEmail.value) {
            form.verifiedEmail.value = false;
          }
          onChanged();
        },
      ),
      const SizedBox(height: 6),
      Text(
        form.verifiedMobile.value
            ? 'Lowercase only.'
            : 'Verify your mobile number first.',
        style: BbhOnboardingText.manrope(
          size: 12,
          color: BbhOnboardingColors.muted,
        ),
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
    ]);
  }

  //   static Widget contact(
  //     BbhOnboardingForm form,
  //     VoidCallback onChanged, {
  //     required Future<void> Function(BbhOnboardingOtpChannel channel) onVerify,
  //   }) {
  //     return _scroll([
  //       const BbhStepHeader(
  //         eyebrow: 'Step 8 · Contact & Verification',
  //         title: 'Where can we reach you?',
  //       ),
  //       const SizedBox(height: 20),
  //       BbhTextField(
  //   controller: form.mobile,
  //   label: 'Mobile Number',
  //   hint: '+964 7XX XXX XXXX',
  //   keyboardType: TextInputType.phone,
  //   verified: form.verifiedMobile.value,
  //   onChanged: (_) {
  //     if (form.verifiedMobile.value) {
  //       form.verifiedMobile.value = false;
  //     }
  //     onChanged();
  //   },
  // ),
  //       // BbhTextField(
  //       //   controller: form.email,
  //       //   label: 'Email Address',
  //       //   hint: 'client@example.com',
  //       //   keyboardType: TextInputType.emailAddress,
  //       //   verified: form.verifiedEmail.value,
  //       //   capitalization: TextCapitalization.none,
  //       //   onChanged: (_) {
  //       //     if (form.verifiedEmail.value) {
  //       //       form.verifiedEmail.value = false;
  //       //     }
  //       //     if (form.verifiedMobile.value) {
  //       //       form.verifiedMobile.value = false;
  //       //     }
  //       //     onChanged();
  //       //   },
  //       // ),

  //       const SizedBox(height: 6),
  //       Text(
  //         'Lowercase only. Verify your email first.',
  //         style: BbhOnboardingText.manrope(
  //           size: 12,
  //           color: BbhOnboardingColors.muted,
  //         ),
  //       ),
  //       Align(
  //         alignment: Alignment.centerRight,
  //         child: SizedBox(
  //           width: 148,
  //           child: BbhGhostButton(
  //   label: form.verifiedMobile.value
  //       ? 'Verified ✓'
  //       : 'Verify Number',
  //   onPressed: form.verifiedMobile.value
  //       ? null
  //       : () => onVerify(BbhOnboardingOtpChannel.mobile),
  // ),
  //           // BbhGhostButton(
  //           //   label: form.verifiedEmail.value ? 'Verified ✓' : 'Verify Email',
  //           //   onPressed: form.verifiedEmail.value
  //           //       ? null
  //           //       : () => onVerify(BbhOnboardingOtpChannel.email),
  //           // ),
  //         ),
  //       ),
  //       BbhTextField(
  //   controller: form.email,
  //   label: 'Email Address',
  //   hint: 'client@example.com',
  //   keyboardType: TextInputType.emailAddress,
  //   verified: form.verifiedEmail.value,
  //   capitalization: TextCapitalization.none,
  //   onChanged: (_) {
  //     if (form.verifiedEmail.value) {
  //       form.verifiedEmail.value = false;
  //     }
  //     onChanged();
  //   },
  // ),
  //       // BbhTextField(
  //       //   controller: form.mobile,
  //       //   label: 'Mobile Number',
  //       //   hint: '+964 7XX XXX XXXX',
  //       //   keyboardType: TextInputType.phone,
  //       //   verified: form.verifiedMobile.value,
  //       //   onChanged: (_) {
  //       //     if (form.verifiedMobile.value) {
  //       //       form.verifiedMobile.value = false;
  //       //     }
  //       //     onChanged();
  //       //   },
  //       // ),
  //       const SizedBox(height: 6),
  //       Text(
  //         form.verifiedEmail.value
  //             ? 'International format with country code.'
  //             : 'Verify your email first, then verify your mobile number.',
  //         style: BbhOnboardingText.manrope(
  //           size: 12,
  //           color: BbhOnboardingColors.muted,
  //         ),
  //       ),
  //       Align(
  //         alignment: Alignment.centerRight,
  //         child: SizedBox(
  //           width: 148,
  //           child: BbhGhostButton(
  //   label: form.verifiedEmail.value
  //       ? 'Verified ✓'
  //       : 'Verify Email',
  //   onPressed: form.verifiedEmail.value || !form.verifiedMobile.value
  //       ? null
  //       : () => onVerify(BbhOnboardingOtpChannel.email),
  // ),
  //           // BbhGhostButton(
  //           //   label: form.verifiedMobile.value ? 'Verified ✓' : 'Verify Number',
  //           //   onPressed: form.verifiedMobile.value || !form.verifiedEmail.value
  //           //       ? null
  //           //       : () => onVerify(BbhOnboardingOtpChannel.mobile),
  //           // ),
  //         ),
  //       ),
  //     ]);
  //   }

  static Widget custodian(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Section 5 · Custodian',
        title: 'Where do you want your assets to be held?',
        lede: 'Your gold and Iraqi Dinars are held by our partner bank.',
      ),
      const SizedBox(height: 6),
      Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
            decoration: BoxDecoration(
              color: BbhOnboardingColors.paperWarm,
              borderRadius: BorderRadius.circular(BbhOnboardingRadii.lg),
              border: Border.all(color: BbhOnboardingColors.gold, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26B8924A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Al-Taif Islamic Bank',
                  style: BbhOnboardingText.display(
                    size: 19,
                    weight: FontWeight.w600,
                    color: BbhOnboardingColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your gold and Iraqi Dinars are held in segregated custody at Al-Taif Islamic Bank, with bank-grade security and reconciliation. Your onboarding details will be shared with Al-Taif.',
                  style: BbhOnboardingText.manrope(
                    size: 13,
                    color: BbhOnboardingColors.inkSoft,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'BANK CUSTODY',
                  style: BbhOnboardingText.manrope(
                    size: 9.5,
                    weight: FontWeight.w600,
                    letterSpacing: 1.8,
                    color: BbhOnboardingColors.goldDeep,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: BbhOnboardingColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '✓',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Container(height: 1, color: BbhOnboardingColors.ruleSoft),
      const SizedBox(height: 24),
      BbhToggleGroup(
        label: 'Do you already have an account with this bank?',
        value: form.hasAccount,
        options: const ['No', 'Yes'],
        onChanged: (v) {
          form.hasAccount = v;
          if (v == 'No') form.iban.clear();
          onChanged();
        },
      ),
      if (form.hasAccount == 'Yes') ...[
        const SizedBox(height: 4),
        BbhTextField(
          fieldKey: 'iban',
          controller: form.iban,
          label: 'Account number (IBAN)',
          hint: 'IQ00 0000 0000 0000 0000 000',
          capitalization: TextCapitalization.characters,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 6),
        Text(
          'Your Iraqi IBAN begins with IQ and is 23 characters long. You can find it in your bank app or on a statement.',
          style: BbhOnboardingText.manrope(
            size: 12.5,
            color: BbhOnboardingColors.muted,
            height: 1.6,
          ),
        ),
      ] else ...[
        const SizedBox(height: 16),
        Text(
          'If you do not have an account, your onboarding details will be sent to the bank to open a personal account for you in Iraqi Dinars (IQD).',
          style: BbhOnboardingText.manrope(
            size: 12.5,
            color: BbhOnboardingColors.muted,
            height: 1.6,
          ),
        ),
      ],
    ]);
  }

  static Widget consent(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Section 6 · Consent & Authorisation',
        title: 'Consent',
        lede: 'Please read before signing.',
      ),
      const SizedBox(height: 16),
      const BbhClauseItem(
        number: '6.1',
        bold: 'Collection.',
        body:
            'I authorise BBH to collect and keep the information and documents captured during this onboarding.',
      ),
      const BbhClauseItem(
        number: '6.2',
        bold: 'Permitted use.',
        body:
            "BBH may use my information only to (a) open and operate my BBH gold account, (b) settle my gold purchases and sales with BBH, and (c) discharge BBH's legal and compliance obligations.",
      ),
      const BbhClauseItem(
        number: '6.3',
        bold: 'Custodian bank.',
        body:
            'My gold and Iraqi Dinars will be held in custody at Al-Taif Islamic Bank. I authorise BBH to share this onboarding information with Al-Taif Islamic Bank to open my custody account there.',
      ),
      const BbhClauseItem(
        number: '6.4',
        bold: 'Excluded purposes.',
        body:
            'This consent does not authorise BBH or any partner bank to offer me credit cards, loans, financing, insurance, or unrelated investment products.',
      ),
      const BbhClauseItem(
        number: '6.5',
        bold: 'Retention.',
        body:
            'BBH retains these records for not less than seven (7) years from the closure of the account or last transaction.',
      ),
      const SizedBox(height: 2),
      Center(
        child: Text(
          '◆ ◆ ◆',
          style: BbhOnboardingText.display(
            size: 14,
            color: BbhOnboardingColors.goldDeep,
          ),
        ),
      ),
      const SizedBox(height: 12),
      BbhTextField(controller: form.signerName, label: 'Full Name'),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerLeft,
        child: Text('Signature', style: BbhOnboardingText.fieldLabel()),
      ),
      const SizedBox(height: 8),
      Builder(
        builder: (context) => BbhSignatureTrigger(
          fieldKey: 'signature',
          hasSignature: form.hasSignature,
          onTap: () => BbhSignatureDialog.show(
            context,
            hasSignature: form.hasSignature,
            onSignatureChanged: (value) {
              form.signature = value;
              onChanged();
            },
          ),
        ),
      ),
      const SizedBox(height: 16),
      BbhConfirmRow(
        fieldKey: 'consent_confirmed',
        text:
            'I have read clauses 6.1 to 6.5, understand them, and give consent.',
        checked: form.consentConfirmed,
        onChanged: (_) {
          form.consentConfirmed = !form.consentConfirmed;
          onChanged();
        },
      ),
    ]);
  }

  static Widget review(
    BbhOnboardingForm form, {
    required void Function(String sectionKey) onEditSection,
  }) {
    String v(TextEditingController c) => c.text.trim();
    String yesNo(String value) => value == 'Yes'
        ? 'Yes'
        : value == 'No'
        ? 'No'
        : '';
    String captured(bool done) => done ? '✓ Captured' : '—';
    String verifiedContact(String value, bool isVerified) {
      if (value.isEmpty) return '';
      if (!isVerified) return value;
      return '$value  ✓ Verified';
    }

    String fullEn() => [
      v(form.enFirst),
      v(form.enFather),
      v(form.enGf),
      v(form.enSurname),
    ].where((e) => e.isNotEmpty).join(' ');
    String fullAr() => [
      v(form.arFirst),
      v(form.arFather),
      v(form.arGf),
      v(form.arSurname),
    ].where((e) => e.isNotEmpty).join(' ');
    String landmark() {
      final en = v(form.addrLandmarkEn);
      final ar = v(form.addrLandmarkAr);
      if (en.isEmpty && ar.isEmpty) return '';
      return en.isNotEmpty ? en : ar;
    }

    String incomeDisplay() {
      final digits = v(form.income).replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) return '';
      final n = int.tryParse(digits);
      if (n == null) return v(form.income);
      return intl.NumberFormat.decimalPattern('en_US').format(n);
    }

    String streetNo() => [
      v(form.addrStreet),
      v(form.addrHouse),
    ].where((e) => e.isNotEmpty).join(' / ');

    final sections = <_ReviewSectionData>[
      _ReviewSectionData(
        key: 'contact',
        title: 'Contact',
        rows: [
          _ReviewRow(
            'Mobile',
            verifiedContact(v(form.mobile), form.verifiedMobile.value),
          ),
          _ReviewRow(
            'Email',
            verifiedContact(v(form.email), form.verifiedEmail.value),
          ),
        ],
      ),
      _ReviewSectionData(
        key: 'name',
        title: 'Name',
        rows: [
          _ReviewRow('Name (EN)', fullEn()),
          _ReviewRow('Name (AR)', fullAr()),
          _ReviewRow("Mother's Name (AR)", v(form.arMother)),
        ],
      ),
      _ReviewSectionData(
        key: 'personal',
        title: 'Personal Details',
        rows: [
          _ReviewRow('Gender', form.gender ?? ''),
          _ReviewRow('DOB', v(form.dob)),
          _ReviewRow('Nationality', v(form.nationality)),
        ],
      ),
      _ReviewSectionData(
        key: 'natid',
        title: 'National ID',
        rows: [
          _ReviewRow('Personal No.', v(form.idPersonal)),
          _ReviewRow('Card Serial', v(form.idSerial)),
          _ReviewRow('Issued', v(form.idIssueDate)),
          _ReviewRow('Expires', v(form.idExpiryDate)),
        ],
      ),
      if (form.noPassport)
        _ReviewSectionData(
          key: 'passport',
          title: 'Passport',
          rows: [_ReviewRow('Status', 'No passport on file')],
        )
      else
        _ReviewSectionData(
          key: 'passport',
          title: 'Passport',
          rows: [
            _ReviewRow('Number', v(form.ppNo)),
            _ReviewRow('Place', v(form.ppPlace)),
            _ReviewRow('Issued', v(form.ppIssue)),
            _ReviewRow('Expires', v(form.ppExpiry)),
          ],
        ),
      _ReviewSectionData(
        key: 'income',
        title: 'Income',
        rows: [
          _ReviewRow('Education', form.education ?? ''),
          _ReviewRow('Sector', form.sector ?? ''),
          _ReviewRow('Income (IQD)', incomeDisplay()),
          _ReviewRow('Occupation', v(form.occupation)),
          _ReviewRow('Employer', v(form.employer)),
        ],
      ),
      _ReviewSectionData(
        key: 'address',
        title: 'Address',
        rows: [
          _ReviewRow('Governorate', v(form.addrGov)),
          _ReviewRow('District', v(form.addrDistrict)),
          _ReviewRow('City/Town', v(form.addrCity)),
          _ReviewRow('Mahalla', v(form.addrMahalla)),
          _ReviewRow('Street/No.', streetNo()),
          _ReviewRow('Landmark', landmark()),
        ],
      ),
      _ReviewSectionData(
        key: 'compliance',
        title: 'Compliance',
        rows: [
          _ReviewRow('FATCA U.S. Person', yesNo(form.fatca)),
          _ReviewRow('PEP Status', yesNo(form.pep)),
          if (form.noPassport) _ReviewRow('Passport on file', 'No'),
        ],
      ),
      _ReviewSectionData(
        key: 'foreignres',
        title: 'Foreign Residency',
        rows: [
          _ReviewRow(
            'Permission to Reside Outside Iraq',
            yesNo(form.foreignRes),
          ),
          if (form.foreignRes == 'Yes') ...[
            _ReviewRow('Country', v(form.foreignResCountry)),
            _ReviewRow('Residency Permit', captured(form.foreignResCaptured)),
          ],
        ],
      ),
      _ReviewSectionData(
        key: 'foreigncit',
        title: 'Foreign Citizenship',
        rows: [
          _ReviewRow('Citizenship in Another Country', yesNo(form.foreignCit)),
          if (form.foreignCit == 'Yes') ...[
            _ReviewRow('Country', v(form.foreignCitCountry)),
            _ReviewRow('Foreign Passport', captured(form.foreignCitCaptured)),
          ],
        ],
      ),
      _ReviewSectionData(
        key: 'biometrics',
        title: 'Identity Verification',
        rows: [
          _ReviewRow('ID Front', captured(form.idFrontCaptured)),
          _ReviewRow('ID Back', captured(form.idBackCaptured)),
          _ReviewRow(
            'Passport',
            form.noPassport
                ? 'Not applicable'
                : captured(form.passportCaptured),
          ),
          _ReviewRow('Residence Front', captured(form.resFrontCaptured)),
          _ReviewRow('Residence Back', captured(form.resBackCaptured)),
        ],
      ),
      _ReviewSectionData(
        key: 'custodian',
        title: 'Custodian',
        rows: [
          _ReviewRow('Held With', 'Al-Taif Islamic Bank'),
          _ReviewRow('Existing Account', yesNo(form.hasAccount)),
          if (form.hasAccount == 'Yes') _ReviewRow('IBAN', v(form.iban)),
        ],
      ),
    ];

    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Final Review',
        title: 'Review before submission',
        lede: 'Tap any section to edit. Submission is final.',
      ),
      const SizedBox(height: 16),
      for (final section in sections)
        _reviewSection(
          title: section.title,
          onEdit: () => onEditSection(section.key),
          rows: section.rows
              .map((r) => (r.label, displayText(r.value)))
              .toList(),
        ),
      const SizedBox(height: 2),
      Center(
        child: Text(
          '◆ ◆ ◆',
          style: BbhOnboardingText.display(
            size: 14,
            color: BbhOnboardingColors.goldDeep,
          ),
        ),
      ),
      const SizedBox(height: 14),
      Center(
        child: Text(
          'Once submitted, this pack will be sent to Al-Taif Islamic Bank for processing.',
          textAlign: TextAlign.center,
          style: BbhOnboardingText.display(
            size: 14,
            color: BbhOnboardingColors.muted,
          ).copyWith(fontStyle: FontStyle.italic),
        ),
      ),
    ]);
  }

  static String displayText(String value) =>
      value.trim().isEmpty ? '— not provided —' : value.trim();

  static Widget success({
    required String? kycRef,
    required VoidCallback onRestart,
  }) {
    return ColoredBox(
      color: BbhOnboardingColors.cream,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: BbhOnboardingColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Submission Complete',
                    style: BbhOnboardingText.stepEyebrow(),
                  ),
                  const SizedBox(height: 8),
                  Text('Pack Submitted', style: BbhOnboardingText.stepTitle()),
                  const SizedBox(height: 12),
                  Text(
                    'Your onboarding pack has been received and is being processed by BBH.',
                    textAlign: TextAlign.center,
                    style: BbhOnboardingText.manrope(
                      size: 14,
                      color: BbhOnboardingColors.muted,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BbhOnboardingColors.paper,
                      borderRadius: BorderRadius.circular(
                        BbhOnboardingRadii.md,
                      ),
                      border: Border.all(color: BbhOnboardingColors.rule),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KYC Reference',
                          style: BbhOnboardingText.fieldLabel(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          kycRef ?? 'BBH-KYC-XXXX',
                          style: BbhOnboardingText.display(
                            size: 20,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Submitted just now',
                          style: BbhOnboardingText.manrope(
                            size: 12,
                            color: BbhOnboardingColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: BbhOnboardingColors.paper,
                      borderRadius: BorderRadius.circular(
                        BbhOnboardingRadii.md,
                      ),
                      border: Border.all(color: BbhOnboardingColors.rule),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What happens next',
                          style: BbhOnboardingText.manrope(
                            size: 14,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _successItem('BBH receives the pack within minutes'),
                        _successItem(
                          'Account opening is normally completed within 2 business days',
                        ),
                        _successItem(
                          'BBH retains a digital copy for not less than 7 years',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  BbhPrimaryButton(
                    label: 'Start a new onboarding',
                    onPressed: onRestart,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _scroll(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  static Widget _preflightItem({
    required String icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paper,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: BbhOnboardingColors.creamDeep,
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BbhOnboardingText.display(
                    size: 17,
                    weight: FontWeight.w600,
                    color: BbhOnboardingColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: BbhOnboardingText.manrope(
                    size: 12.5,
                    color: BbhOnboardingColors.muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _groupTitle(String title, String? sub) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: sub != null ? 16 : 12,
        top: title.isEmpty ? 0 : 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(
              title,
              style: BbhOnboardingText.display(
                size: 21,
                weight: FontWeight.w600,
              ),
            ),
          if (sub != null) ...[
            if (title.isNotEmpty) const SizedBox(height: 2),
            Text(
              sub,
              style: BbhOnboardingText.manrope(
                size: 13,
                color: BbhOnboardingColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _grid2(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, c) {
          if (c.maxWidth < 360) {
            return Column(children: [left, const SizedBox(height: 12), right]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: 14),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }

  static Widget editDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String? fieldKey,
  }) => _dropdown(label, value, items, onChanged, fieldKey: fieldKey);

  static Widget _dropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String? fieldKey,
  }) {
    final showError = BbhOnboardingFieldScroll.isError(fieldKey);
    final content = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: BbhOnboardingText.fieldLabel()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: BbhOnboardingColors.paper,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm),
                borderSide: BorderSide(
                  color: showError
                      ? BbhOnboardingColors.error
                      : BbhOnboardingColors.rule,
                ),
              ),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select…')),
              ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
            ],
            onChanged: (v) {
              if (showError) BbhOnboardingFieldScroll.clearError();
              onChanged(v);
            },
          ),
        ],
      ),
    );
    if (fieldKey == null) return content;
    return BbhOnboardingFieldScroll.anchor(fieldKey, content);
  }

  static Widget _fieldWithHint(Widget field, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        const SizedBox(height: 6),
        Text(
          hint,
          style: BbhOnboardingText.fieldHint(),
        ),
      ],
    );
  }

  static Widget _successItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.check,
              size: 15,
              color: BbhOnboardingColors.success,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: BbhOnboardingText.manrope(
                size: 13.2,
                color: BbhOnboardingColors.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _reviewSection({
    required String title,
    required VoidCallback onEdit,
    required List<(String label, String value)> rows,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paper,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: BbhOnboardingText.manrope(
                      size: 13,
                      weight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: BbhOnboardingColors.goldDeep,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: BbhOnboardingColors.goldDeep,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Edit',
                    style: BbhOnboardingText.manrope(
                      size: 12,
                      weight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      rows[i].$1.toUpperCase(),
                      style: BbhOnboardingText.manrope(
                        size: 10.5,
                        weight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: BbhOnboardingColors.muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.end,
                      style:
                          BbhOnboardingText.manrope(
                            size: 13.5,
                            color: rows[i].$2 == '— not provided —'
                                ? BbhOnboardingColors.muted
                                : BbhOnboardingColors.ink,
                            height: 1.45,
                          ).copyWith(
                            fontStyle: rows[i].$2 == '— not provided —'
                                ? FontStyle.italic
                                : FontStyle.normal,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                color: BbhOnboardingColors.ruleSoft,
              ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _ReviewRow {
  const _ReviewRow(this.label, this.value);
  final String label;
  final String value;
}

class _ReviewSectionData {
  const _ReviewSectionData({
    required this.key,
    required this.title,
    required this.rows,
  });
  final String key;
  final String title;
  final List<_ReviewRow> rows;
}
