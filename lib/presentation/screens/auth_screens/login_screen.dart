import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:saveingold_fzco/core/core_export.dart';
import 'package:saveingold_fzco/data/data_sources/local_database/local_database.dart';
import 'package:saveingold_fzco/presentation/screens/auth_screens/register_screen.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/setting_provider/check_device_security.dart';
import 'package:saveingold_fzco/presentation/widgets/button_widget.dart';

import 'forgot_screens/forgot_password_screen.dart';

enum LoginType { phone, email, bank }

class CountryCode {
  final String code;
  final String dialCode;
  final String flag;

  CountryCode({
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  LoginType _selectedType = LoginType.phone;

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final bankIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _hasSubmitted = false;

  final _formKey = GlobalKey<FormState>();

  CountryCode _selectedCountry = CountryCode(
    code: "IQ",
    dialCode: "+964",
    flag: "assets/svg/iraq.svg",
  );

  final List<CountryCode> _countries = [
    CountryCode(code: "IQ", dialCode: "+964", flag: "assets/svg/iraq.svg"),
    CountryCode(code: "AE", dialCode: "+971", flag: "assets/svg/ae_flag.svg"),
  ];

  late final ValueNotifier<bool> _isFormValidNotifier;

  @override
  void initState() {
    super.initState();
    _isFormValidNotifier = ValueNotifier<bool>(_isFormValid());

    void updateValidity() {
      _isFormValidNotifier.value = _isFormValid();
    }

    phoneController.addListener(updateValidity);
    emailController.addListener(updateValidity);
    bankIdController.addListener(updateValidity);
    passwordController.addListener(updateValidity);
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    bankIdController.dispose();
    passwordController.dispose();
    _isFormValidNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateWatch = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/png/bg_start.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                autovalidateMode: _hasSubmitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 60),

                    Text(
                      _selectedType == LoginType.bank
                          ? "Bank login"
                          : "Welcome back",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSubtitleText(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildInputSection(),

                    const SizedBox(height: 20),

                    ValueListenableBuilder<bool>(
                      valueListenable: _isFormValidNotifier,
                      builder: (context, isValid, child) {
                        return ButtonWidget(
                          title: _selectedType == LoginType.bank
                              ? "Login"
                              : "Continue",
                          isLoadingState: authStateWatch.isButtonState,
                          enabled: isValid,
                          onTap: _handleLogin,
                        );
                      },
                    ),

                    _buildBiometricLoginIfAvailable(),

                    const SizedBox(height: 20),
                    _buildDivider(),
                    const SizedBox(height: 20),

                    if (_selectedType != LoginType.phone)
                      _buildSecondaryButton(
                        "Login with phone",
                        () {
                          setState(() => _selectedType = LoginType.phone);
                          _isFormValidNotifier.value = _isFormValid();
                        },
                      ),
                    if (_selectedType != LoginType.email)
                      _buildSecondaryButton(
                        "Login with email",
                        () {
                          setState(() => _selectedType = LoginType.email);
                          _isFormValidNotifier.value = _isFormValid();
                        },
                      ),

                    // if (_selectedType != LoginType.bank)
                    //   _buildSecondaryButton(
                    //     "Login with bank",
                    //     () => setState(() => _selectedType = LoginType.bank),
                    //   ),
                    const SizedBox(height: 5),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "I'm new to BBH",
                          style: TextStyle(
                            color: Color(0xFFC5A353),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- INPUT SECTION ----------------

  Widget _buildInputSection() {
    switch (_selectedType) {
      case LoginType.phone:
        return Column(
          children: [
            Row(
              children: [
                _buildCountryDropdown(),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: phoneController,
                    hint: "Phone number",
                    isNumeric: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      final digitsOnly = value.replaceAll(
                        RegExp(r'[^0-9]'),
                        '',
                      );
                      if (digitsOnly.length < 9) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: passwordController,
              hint: "**********",
              label: "Password",
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            _buildForgotPassword(),
          ],
        );

      case LoginType.email:
        return Column(
          children: [
            _buildTextField(
              controller: emailController,
              hint: "Enter your email",
              label: "Email",
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter email';
                }
                if (!value.trim().validateEmail()) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: passwordController,
              hint: "**********",
              label: "Password",
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            _buildForgotPassword(),
          ],
        );

      case LoginType.bank:
        return Column(
          children: [
            _buildTextField(
              controller: bankIdController,
              hint: "Enter your user ID",
              label: "User ID",
              showWarning: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your user ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: passwordController,
              hint: "**********",
              label: "Password",
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
            _buildForgotPassword(),
          ],
        );
    }
  }

  /// ---------------- TEXT FIELD ----------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? label,
    bool isPassword = false,
    bool isNumeric = false,
    bool showWarning = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          validator: validator,
          keyboardType: isNumeric
              ? TextInputType.number
              : TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: showWarning
                ? const Icon(Icons.error_outline, color: Colors.white54)
                : isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC5A353)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  /// ---------------- COUNTRY DROPDOWN ----------------

  Widget _buildCountryDropdown() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CountryCode>(
          value: _selectedCountry,
          dropdownColor: const Color(0xFF2A2A2A),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCountry = value);
            }
          },
          items: _countries.map((country) {
            return DropdownMenuItem(
              value: country,
              child: Row(
                children: [
                  SvgPicture.asset(
                    country.flag,
                    width: 22,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.flag, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    country.dialCode,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// ---------------- HELPERS ----------------

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 55),
          side: const BorderSide(color: Color(0xFFC5A353)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildBiometricLoginIfAvailable() {
    final isIOS = Platform.isIOS;
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        LocalDatabase.instance.areCredentialsSaved(),
        isIOS
            ? BiometricUtils.isFaceLockAvailable()
            : BiometricUtils.isFingerprintAvailable(),
        isIOS
            ? LocalDatabase.instance.getFaceEnable()
            : LocalDatabase.instance.getFingerEnable(),
      ]),
      builder: (context, snapshot) {
        final credentialsSaved = snapshot.data?[0] == true;
        final biometricAvailable = snapshot.data?[1] == true;
        final biometricEnabledInSettings = snapshot.data?[2] == true;
        if (snapshot.connectionState != ConnectionState.done ||
            !credentialsSaved ||
            !biometricAvailable ||
            !biometricEnabledInSettings) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (isIOS) {
                    await ref
                        .read(authProvider.notifier)
                        .authenticateWithFaceUnlock(context: context);
                  } else {
                    await ref
                        .read(authProvider.notifier)
                        .authenticateWithFingerprint(context: context);
                  }
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFC5A353),
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      isIOS
                          ? "assets/svg/faceId_icon.svg"
                          : "assets/svg/fingerprint_icon.svg",
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFC5A353),
                        BlendMode.srcIn,
                      ),
                      errorBuilder: (_, __, ___) => Icon(
                        isIOS ? Icons.face : Icons.fingerprint,
                        color: const Color(0xFFC5A353),
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.white24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("Or", style: TextStyle(color: Colors.white54)),
        ),
        Expanded(child: Divider(color: Colors.white24)),
      ],
    );
  }

  String _getSubtitleText() {
    switch (_selectedType) {
      case LoginType.bank:
        return "Enter your banking details to login with your bank";
      case LoginType.email:
        return "Enter your email to login";
      case LoginType.phone:
        return "Enter your phone number to login";
    }
  }

  bool _isFormValid() {
    final password = passwordController.text.trim();
    if (password.isEmpty) return false;

    switch (_selectedType) {
      case LoginType.phone:
        final phone = phoneController.text.trim();
        final digitsOnly = phone.replaceAll(RegExp(r'[^0-9]'), '');
        return digitsOnly.length >= 9;
      case LoginType.email:
        final email = emailController.text.trim();
        return email.validateEmail();
      case LoginType.bank:
        final bankId = bankIdController.text.trim();
        return bankId.isNotEmpty;
    }
  }

  void _handleLogin() async {
    setState(() => _hasSubmitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      String loginIdentifier;

      if (_selectedType == LoginType.phone) {
        final dialCode = _selectedCountry.dialCode.replaceFirst('+', '00');

        loginIdentifier = "$dialCode${phoneController.text.trim()}";
      } else if (_selectedType == LoginType.email) {
        loginIdentifier = emailController.text.trim();
      } else {
        loginIdentifier = bankIdController.text.trim();
      }

      await ref
          .read(authProvider.notifier)
          .userLogin(
            email: loginIdentifier,
            password: passwordController.text.trim(),
            context: context,
            showLoader: true,
            isFinger: false,
          );
    }
  }
}
