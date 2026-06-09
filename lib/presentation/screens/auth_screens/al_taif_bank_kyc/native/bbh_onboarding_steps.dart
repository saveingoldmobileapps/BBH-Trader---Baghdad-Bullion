import 'package:baghdad_bullion_house/services/ipass_kyc/ipass_onboarding_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bbh_onboarding_form.dart';
import 'bbh_onboarding_theme.dart';
import 'bbh_onboarding_widgets.dart';

/// Builds native Flutter content for each onboarding step.
class BbhOnboardingSteps {
  BbhOnboardingSteps._();

  static const educationLevels = [
    'Primary', 'Secondary', 'Diploma', "Bachelor's", "Master's", 'Doctorate', 'Other',
  ];

  static const sectors = [
    'Trade — Gold & Bullion', 'Trade — General', 'Manufacturing', 'Agriculture',
    'Construction', 'Real Estate', 'Financial Services', 'Public Sector',
    'Healthcare', 'Education', 'Other Services', 'Not Applicable',
  ];

  static const governorates = [
    'Baghdad', 'Basra', 'Nineveh', 'Erbil', 'Najaf', 'Karbala', 'Anbar', 'Dhi Qar',
    'Babil', 'Diyala', 'Kirkuk', 'Saladin', 'Wasit', 'Maysan', 'Muthanna', 'Qadisiyyah',
    'Sulaymaniyah', 'Duhok', 'Halabja',
  ];

  static Widget cover({required VoidCallback onBegin, required VoidCallback onExit}) {
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
                      Image.asset('assets/png/app_ic.png', height: 88, width: 88),
                      const SizedBox(height: 24),
                      Text(
                        'BAGHDAD\nBULLION HOUSE',
                        textAlign: TextAlign.center,
                        style: BbhOnboardingText.display(
                          size: 38,
                          weight: FontWeight.w600,
                          color: const Color(0xFFF0E2BD),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'دار بغداد لصياغة الذهب والفضة والسبائك الذهبية',
                        textAlign: TextAlign.center,
                        style: BbhOnboardingText.arabic(size: 18, color: const Color(0xD9E8D49E)),
                      ),
                      const SizedBox(height: 20),
                      Container(width: 48, height: 1, color: BbhOnboardingColors.gold.withValues(alpha: 0.5)),
                      const SizedBox(height: 20),
                      Text(
                        'Clasific',
                        textAlign: TextAlign.center,
                        style: BbhOnboardingText.manrope(
                          size: 13,
                          color: BbhOnboardingColors.coverText.withValues(alpha: 0.75),
                        ),
                      ),
                      const Spacer(flex: 2),
                      BbhPrimaryButton(label: 'Begin Onboarding', onPressed: onBegin),
                      const SizedBox(height: 10),
                      BbhGhostButton(label: 'Exit', onPressed: onExit, onDark: true),
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
        lede: 'All three documents below are required to complete onboarding. Please have them with you before continuing.',
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
        body: 'BBH is a licensed dealer in precious metals and stones, registered in Iraq under Commercial Registration No. 17240, with four (4) branches in Baghdad and one (1) in Najaf.',
      ),
      const BbhClauseItem(
        number: '1.2',
        bold: 'What we collect.',
        body: 'This onboarding captures your identifying details, economic profile, and compliance declarations to open your gold account with BBH.',
      ),
      const BbhClauseItem(
        number: '1.3',
        bold: 'What we keep.',
        body: 'All records are held securely by BBH for the period required by Iraqi law, not less than seven (7) years from the closure of the account or last transaction.',
      ),
      const SizedBox(height: 8),
      BbhConfirmRow(
        text: 'I have been informed of the above and wish to proceed with BBH onboarding.',
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
        title: "Let's start with your documents",
        lede: "Capture each document clearly. We'll read your details automatically and you can review them on the next screen.",
      ),
      const SizedBox(height: 20),
      BbhDocCaptureRow(
        badge: '1',
        title: 'National ID (Front and Back)',
        captured: idCaptured,
        loading: ipassLoadingTarget == IpassScanTarget.nationalId && !idCaptured,
        onCapture: () => onIpassCapture(IpassScanTarget.nationalId),
        onReplace: idCaptured ? () => onIpassCapture(IpassScanTarget.nationalId) : null,
      ),
      BbhDocCaptureRow(
        badge: '2',
        title: 'Residence Card (Front and Back)',
        captured: resCaptured,
        loading: ipassLoadingTarget == IpassScanTarget.residence && !resCaptured,
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
          loading: ipassLoadingTarget == IpassScanTarget.passport && !form.passportCaptured,
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

  static Widget ocrReview(BbhOnboardingForm form, VoidCallback onChanged, Future<void> Function(TextEditingController, String) pickDate) {
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
      _groupTitle('Full name in Arabic', 'As written on the national identity card.'),
      _grid2(
        BbhTextField(controller: form.arFirst, label: 'First Name', locked: form.isLocked('ar_first'), verified: form.isLocked('ar_first'), textDirection: TextDirection.rtl),
        BbhTextField(controller: form.arFather, label: "Father's Name", locked: form.isLocked('ar_father'), verified: form.isLocked('ar_father'), textDirection: TextDirection.rtl),
      ),
      _grid2(
        BbhTextField(controller: form.arGf, label: "Grandfather's", locked: form.isLocked('ar_gf'), verified: form.isLocked('ar_gf'), textDirection: TextDirection.rtl),
        BbhTextField(controller: form.arSurname, label: 'Surname', locked: form.isLocked('ar_surname'), verified: form.isLocked('ar_surname'), textDirection: TextDirection.rtl),
      ),
      BbhTextField(controller: form.arMother, label: "Mother's Name", locked: form.isLocked('ar_mother'), verified: form.isLocked('ar_mother'), textDirection: TextDirection.rtl),
      const SizedBox(height: 24),
      _groupTitle('Full name in English', form.noPassport ? 'Your full name in English (Latin letters).' : 'As it appears on the passport.'),
      _grid2(
        BbhTextField(controller: form.enFirst, label: 'First Name', locked: form.isLocked('en_first'), verified: form.isLocked('en_first'), capitalization: TextCapitalization.words),
        BbhTextField(controller: form.enFather, label: "Father's Name", locked: form.isLocked('en_father'), verified: form.isLocked('en_father'), capitalization: TextCapitalization.words),
      ),
      _grid2(
        BbhTextField(controller: form.enGf, label: "Grandfather's", locked: form.isLocked('en_gf'), verified: form.isLocked('en_gf'), capitalization: TextCapitalization.words),
        BbhTextField(controller: form.enSurname, label: 'Surname', locked: form.isLocked('en_surname'), verified: form.isLocked('en_surname'), capitalization: TextCapitalization.words),
      ),
      BbhTextField(controller: form.enMother, label: "Mother's Name", locked: form.isLocked('en_mother'), verified: form.isLocked('en_mother'), capitalization: TextCapitalization.words),
      const SizedBox(height: 24),
      _groupTitle('National Identity Card', 'Both numbers are printed on the same card.'),
      _grid2(
        BbhTextField(controller: form.idPersonal, label: 'Personal Number', locked: form.isLocked('id_personal'), verified: form.isLocked('id_personal'), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(12)]),
        BbhTextField(controller: form.idSerial, label: 'ID Number (Card Serial)', locked: form.isLocked('id_serial'), verified: form.isLocked('id_serial'), capitalization: TextCapitalization.characters),
      ),
      BbhTextField(controller: form.idIssuePlace, label: 'Place of Issue', locked: form.isLocked('id_issue_place'), verified: form.isLocked('id_issue_place')),
      _grid2(
        BbhTextField(controller: form.idIssueDate, label: 'Date of Issue', readOnly: true, locked: form.isLocked('id_issue_date'), verified: form.isLocked('id_issue_date'), onTap: () => pickDate(form.idIssueDate, 'id_issue_date')),
        BbhTextField(controller: form.idExpiryDate, label: 'Date of Expiry', readOnly: true, locked: form.isLocked('id_expiry_date'), verified: form.isLocked('id_expiry_date'), onTap: () => pickDate(form.idExpiryDate, 'id_expiry_date')),
      ),
      if (!form.noPassport) ...[
        const SizedBox(height: 24),
        _groupTitle('Passport', 'Photo page details.'),
        _grid2(
          BbhTextField(controller: form.ppNo, label: 'Passport Number', locked: form.isLocked('pp_no'), verified: form.isLocked('pp_no')),
          BbhTextField(controller: form.ppPlace, label: 'Place of Issue', locked: form.isLocked('pp_place'), verified: form.isLocked('pp_place')),
        ),
        _grid2(
          BbhTextField(controller: form.ppIssue, label: 'Date of Issue', readOnly: true, locked: form.isLocked('pp_issue'), onTap: () => pickDate(form.ppIssue, 'pp_issue')),
          BbhTextField(controller: form.ppExpiry, label: 'Date of Expiry', readOnly: true, locked: form.isLocked('pp_expiry'), onTap: () => pickDate(form.ppExpiry, 'pp_expiry')),
        ),
      ],
    ]);
  }

  static Widget residenceAddress(BbhOnboardingForm form, VoidCallback onChanged, Future<void> Function(TextEditingController, String) pickDate) {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Step 3 · Residence & Address',
        title: 'Residence card & address',
      ),
      const SizedBox(height: 20),
      _groupTitle('Residence Card', null),
      BbhTextField(controller: form.resNo, label: 'Card Number', locked: form.isLocked('res_no'), verified: form.isLocked('res_no')),
      BbhTextField(controller: form.resPlace, label: 'Place of Issue', locked: form.isLocked('res_place'), verified: form.isLocked('res_place')),
      BbhTextField(controller: form.resIssue, label: 'Date of Issue', readOnly: true, locked: form.isLocked('res_issue'), onTap: () => pickDate(form.resIssue, 'res_issue')),
      const SizedBox(height: 24),
      _groupTitle('Address in Iraq', null),
      _dropdown('Governorate', form.addrGov.text.isEmpty ? null : form.addrGov.text, governorates, (v) { form.addrGov.text = v ?? ''; onChanged(); }),
      _grid2(
        BbhTextField(controller: form.addrDistrict, label: 'District / Qada', locked: form.isLocked('addr_district')),
        BbhTextField(controller: form.addrCity, label: 'City / Town', locked: form.isLocked('addr_city')),
      ),
      _grid2(
        BbhTextField(controller: form.addrMahalla, label: 'Mahalla / Neighbourhood', locked: form.isLocked('addr_mahalla')),
        BbhTextField(controller: form.addrStreet, label: 'Street', locked: form.isLocked('addr_street')),
      ),
      BbhTextField(controller: form.addrHouse, label: 'House / Building No.', locked: form.isLocked('addr_house')),
      BbhTextField(controller: form.addrLandmarkAr, label: 'Nearest Landmark (Arabic)', textDirection: TextDirection.rtl, locked: form.isLocked('addr_landmark_ar')),
      BbhTextField(controller: form.addrLandmarkEn, label: 'Nearest Landmark (English)', locked: form.isLocked('addr_landmark_en')),
      const SizedBox(height: 16),
      BbhToggleGroup(label: 'Foreign residency outside Iraq?', value: form.foreignRes, options: const ['No', 'Yes'], onChanged: (v) { form.foreignRes = v; onChanged(); }),
      if (form.foreignRes == 'Yes') BbhTextField(controller: form.foreignResCountry, label: 'Country of Foreign Residency'),
      const SizedBox(height: 12),
      BbhToggleGroup(label: 'Foreign citizenship?', value: form.foreignCit, options: const ['No', 'Yes'], onChanged: (v) { form.foreignCit = v; onChanged(); }),
      if (form.foreignCit == 'Yes') BbhTextField(controller: form.foreignCitCountry, label: 'Country of Foreign Citizenship'),
    ]);
  }

  static Widget personalDetails(BbhOnboardingForm form, VoidCallback onChanged, Future<void> Function(TextEditingController, String) pickDate) {
    return _scroll([
      const BbhStepHeader(eyebrow: 'Step 4 · Personal Details', title: 'A few personal details'),
      const SizedBox(height: 20),
      BbhToggleGroup(
        label: 'Gender',
        value: form.gender,
        options: const ['Male', 'Female'],
        locked: form.isLocked('gender'),
        onChanged: (v) { form.gender = v; onChanged(); },
      ),
      const SizedBox(height: 16),
      BbhTextField(controller: form.nationality, label: 'Nationality', locked: form.isLocked('nationality'), verified: form.isLocked('nationality')),
      _grid2(
        BbhTextField(controller: form.dob, label: 'Date of Birth', readOnly: true, locked: form.isLocked('dob'), verified: form.isLocked('dob'), onTap: () => pickDate(form.dob, 'dob')),
        BbhTextField(controller: form.countryBirth, label: 'Country of Birth', locked: form.isLocked('country_birth'), verified: form.isLocked('country_birth')),
      ),
      BbhTextField(controller: form.placeBirth, label: 'Place of Birth', hint: 'City or town (max 20 chars)', inputFormatters: [LengthLimitingTextInputFormatter(20)], locked: form.isLocked('place_birth')),
    ]);
  }

  static Widget income(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(eyebrow: 'Step 5 · Income & Employment', title: 'Source of income'),
      const SizedBox(height: 20),
      _dropdown('Education Level', form.education, educationLevels, (v) { form.education = v; onChanged(); }),
      const SizedBox(height: 12),
      _dropdown('Sector', form.sector, sectors, (v) { form.sector = v; onChanged(); }),
      BbhTextField(controller: form.income, label: 'Monthly Income (IQD)', keyboardType: TextInputType.number, hint: 'e.g. 2,500,000'),
      BbhTextField(controller: form.occupation, label: 'Occupation', hint: 'e.g. Goldsmith, Trader, Engineer'),
      BbhTextField(controller: form.employer, label: 'Employer / Status', hint: 'Or Retired, Student, etc.'),
      BbhTextField(controller: form.employerAddr, label: 'Employer Address', maxLines: 3),
    ]);
  }

  static Widget fatca(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(eyebrow: 'Step 6 · FATCA Declaration', title: 'U.S. tax residency'),
      const SizedBox(height: 16),
      const BbhCallout(text: 'FATCA requires financial institutions to report accounts held by U.S. persons. Answer honestly — a "Yes" does not automatically reject your application.'),
      const SizedBox(height: 16),
      BbhToggleGroup(label: 'Are you a U.S. citizen, resident, or green-card holder?', value: form.fatca, options: const ['No', 'Yes'], onChanged: (v) { form.fatca = v; onChanged(); }),
      if (form.fatca == 'Yes') ...[
        BbhTextField(controller: form.fatcaTin, label: 'U.S. TIN'),
        BbhTextField(controller: form.fatcaAddr, label: 'U.S. Address', maxLines: 3),
      ],
    ]);
  }

  static Widget pep(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(eyebrow: 'Step 7 · PEP Declaration', title: 'Politically Exposed Person'),
      const SizedBox(height: 16),
      const BbhCallout(text: 'A Politically Exposed Person (PEP) is someone who holds or has held a prominent public function.'),
      const SizedBox(height: 16),
      BbhToggleGroup(label: 'Are you, or a close associate or family member, a PEP?', value: form.pep, options: const ['No', 'Yes'], onChanged: (v) { form.pep = v; onChanged(); }),
      if (form.pep == 'Yes') ...[
        BbhTextField(controller: form.pepPosition, label: 'Position / Relationship'),
        BbhTextField(controller: form.pepCountry, label: 'Country'),
        _grid2(
          BbhTextField(controller: form.pepFrom, label: 'From (MM/YYYY)', hint: 'MM/YYYY'),
          BbhTextField(controller: form.pepTo, label: 'To (MM/YYYY)', hint: 'MM/YYYY'),
        ),
      ],
    ]);
  }

  static Widget contact(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(eyebrow: 'Step 8 · Contact & Verification', title: 'Where can we reach you?'),
      const SizedBox(height: 20),
      BbhTextField(controller: form.mobile, label: 'Mobile Number', hint: '+964 7XX XXX XXXX', keyboardType: TextInputType.phone, locked: form.isLocked('mobile'), verified: form.verifiedMobile.value),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: form.mobile.text.trim().isEmpty ? null : () { form.verifiedMobile.value = true; onChanged(); },
          child: const Text('Verify'),
        ),
      ),
      BbhTextField(controller: form.email, label: 'Email Address', hint: 'client@example.com', keyboardType: TextInputType.emailAddress, locked: form.isLocked('email'), verified: form.verifiedEmail.value, capitalization: TextCapitalization.none),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: form.email.text.trim().isEmpty ? null : () { form.verifiedEmail.value = true; onChanged(); },
          child: const Text('Verify'),
        ),
      ),
    ]);
  }

  static Widget custodian() {
    return _scroll([
      const BbhStepHeader(
        eyebrow: 'Section 5 · Custodian',
        title: 'Where do you want your assets to be held?',
        lede: 'Your gold and Iraqi Dinars are held by our partner bank.',
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BbhOnboardingColors.paperWarm,
          borderRadius: BorderRadius.circular(BbhOnboardingRadii.lg),
          border: Border.all(color: BbhOnboardingColors.gold, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: BbhOnboardingColors.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text('Al-Taif Islamic Bank', style: BbhOnboardingText.manrope(size: 16, weight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Your gold and Iraqi Dinars are held in segregated custody at Al-Taif Islamic Bank, with bank-grade security and reconciliation.',
              style: BbhOnboardingText.manrope(size: 13.5, color: BbhOnboardingColors.inkSoft, height: 1.5),
            ),
          ],
        ),
      ),
    ]);
  }

  static Widget consent(BbhOnboardingForm form, VoidCallback onChanged) {
    return _scroll([
      const BbhStepHeader(eyebrow: 'Section 6 · Consent & Authorisation', title: 'Consent'),
      const SizedBox(height: 16),
      const BbhClauseItem(number: '6.1', bold: 'Collection.', body: 'I authorise BBH to collect and keep the information, documents, and live photograph captured during this onboarding.'),
      const BbhClauseItem(number: '6.2', bold: 'Sharing.', body: 'I consent to BBH sharing my onboarding data with Al-Taif Islamic Bank for account opening purposes.'),
      BbhTextField(controller: form.signerName, label: 'Signer Name'),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () { form.hasSignature = true; onChanged(); },
        child: Container(
          height: 120,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: BbhOnboardingColors.paper,
            borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
            border: Border.all(color: BbhOnboardingColors.rule, width: 1.5),
          ),
          child: Text(
            form.hasSignature ? 'Signature captured ✓' : 'Tap to sign',
            style: BbhOnboardingText.manrope(color: BbhOnboardingColors.muted, weight: FontWeight.w600),
          ),
        ),
      ),
      const SizedBox(height: 16),
      BbhConfirmRow(
        text: 'I confirm Section 6 has been read and I agree to the terms above.',
        checked: form.consentConfirmed,
        onChanged: (_) { form.consentConfirmed = !form.consentConfirmed; onChanged(); },
      ),
    ]);
  }

  static Widget review(BbhOnboardingForm form) {
    String v(TextEditingController c) => c.text.trim().isEmpty ? '—' : c.text.trim();
    return _scroll([
      const BbhStepHeader(eyebrow: 'Final Review', title: 'Review before submission'),
      const SizedBox(height: 16),
      _reviewSection('Identity', [
        'Name (EN): ${v(form.enFirst)} ${v(form.enFather)} ${v(form.enSurname)}',
        'National ID: ${v(form.idPersonal)}',
        'DOB: ${v(form.dob)}',
      ]),
      _reviewSection('Contact', ['Mobile: ${v(form.mobile)}', 'Email: ${v(form.email)}']),
      _reviewSection('Documents', [
        'ID Front: ${form.idFrontCaptured ? 'Captured ✓' : '—'}',
        'ID Back: ${form.idBackCaptured ? 'Captured ✓' : '—'}',
      ]),
      _reviewSection('Employment', ['Occupation: ${v(form.occupation)}', 'Income: ${v(form.income)}']),
    ]);
  }

  static Widget success({required String? kycRef, required VoidCallback onRestart}) {
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
                    decoration: const BoxDecoration(color: BbhOnboardingColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 20),
                  Text('Pack Submitted', style: BbhOnboardingText.stepTitle()),
                  const SizedBox(height: 12),
                  if (kycRef != null)
                    Text('Reference: $kycRef', style: BbhOnboardingText.manrope(size: 14, color: BbhOnboardingColors.muted)),
                  const SizedBox(height: 32),
                  BbhPrimaryButton(label: 'Start a new onboarding', onPressed: onRestart),
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
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
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BbhOnboardingText.display(size: 21, weight: FontWeight.w600)),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub, style: BbhOnboardingText.manrope(size: 13, color: BbhOnboardingColors.muted)),
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
              const SizedBox(width: 12),
              Expanded(child: right),
            ],
          );
        },
      ),
    );
  }

  static Widget _dropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: BbhOnboardingText.fieldLabel()),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: BbhOnboardingColors.paper,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(BbhOnboardingRadii.sm), borderSide: const BorderSide(color: BbhOnboardingColors.rule)),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Select…')),
              ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  static Widget _reviewSection(String title, List<String> rows) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BbhOnboardingColors.paper,
        borderRadius: BorderRadius.circular(BbhOnboardingRadii.md),
        border: Border.all(color: BbhOnboardingColors.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: BbhOnboardingText.manrope(size: 14, weight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(r, style: BbhOnboardingText.manrope(size: 13, color: BbhOnboardingColors.inkSoft)),
            ),
        ],
      ),
    );
  }
}
