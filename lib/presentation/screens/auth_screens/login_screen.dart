import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saveingold_fzco/presentation/sharedProviders/providers/auth_provider.dart';
import 'package:saveingold_fzco/presentation/widgets/button_widget.dart';

enum LoginType { phone, email, bank }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // State control
  LoginType _selectedType = LoginType.phone;

  // Controllers
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final bankIdController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    bankIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateWatch = ref.watch(authProvider);

    return Scaffold(
      // 1. Extend the body so the background covers the AppBar area
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Keeps AppBar clear
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            // Ensure this path is correct in your pubspec.yaml
            image: AssetImage('assets/png/bg_start.png'),
          ),
        ),
        child: SafeArea(
          // top: false allows the content/background to bleed into the status bar area
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add top padding to account for the transparent AppBar height
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
                  const SizedBox(height: 30),

                  // --- DYNAMIC INPUT SECTION ---
                  _buildInputSection(),

                  const SizedBox(height: 30),

                  // --- PRIMARY BUTTON ---
                  ButtonWidget(
                    title: _selectedType == LoginType.bank
                        ? "Login"
                        : "Continue",
                    isLoadingState: authStateWatch.isButtonState,
                    onTap: _handleLogin,
                  ),

                  const SizedBox(height: 25),
                  _buildDivider(),
                  const SizedBox(height: 25),

                  // --- ALTERNATIVE LOGIN METHODS ---
                  if (_selectedType != LoginType.phone)
                    _buildSecondaryButton(
                      "Login with phone",
                      () => setState(() => _selectedType = LoginType.phone),
                    ),
                  if (_selectedType != LoginType.email)
                    _buildSecondaryButton(
                      "Login with email",
                      () => setState(() => _selectedType = LoginType.email),
                    ),
                  if (_selectedType != LoginType.bank)
                    _buildSecondaryButton(
                      "Login with bank",
                      () => setState(() => _selectedType = LoginType.bank),
                    ),

                  const SizedBox(height: 40),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "I'm new to BBH",
                        style: TextStyle(
                          color: Color(0xFFC5A353),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    switch (_selectedType) {
      case LoginType.phone:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/png/iraq.png",
                    width: 24,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.flag, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "+964",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                phoneController,
                "Placeholder",
                isNumeric: true,
              ),
            ),
          ],
        );

      case LoginType.email:
        return Column(
          children: [
            _buildTextField(
              emailController,
              "Enter your email",
              label: "Email",
            ),
            const SizedBox(height: 20),
            _buildTextField(
              passwordController,
              "**********",
              label: "Password",
              isPassword: true,
            ),
            _buildForgotPassword(),
          ],
        );

      case LoginType.bank:
        return Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildTextField(
                  bankIdController,
                  "Enter your user ID",
                  label: "User ID",
                  showWarning: true,
                ),
                Positioned(
                  top: -45,
                  right: 0,
                  child: _buildBankHint(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              passwordController,
              "**********",
              label: "Password",
              isPassword: true,
            ),
            _buildForgotPassword(),
          ],
        );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isPassword = false,
    bool isNumeric = false,
    String? label,
    bool showWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isNumeric
              ? TextInputType.number
              : TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            suffixIcon: showWarning
                ? const Icon(Icons.error_outline, color: Colors.white54)
                : (isPassword
                      ? const Icon(
                          Icons.visibility_outlined,
                          color: Colors.white54,
                        )
                      : null),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFC5A353)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {}, // Navigate to ForgotPasswordScreen
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

  Widget _buildBankHint() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        "Your user ID is your bank account number",
        style: TextStyle(color: Colors.white70, fontSize: 11),
      ),
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

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      String loginIdentifier = "";

      if (_selectedType == LoginType.phone) {
        loginIdentifier = "00964${phoneController.text.trim()}";
      } else if (_selectedType == LoginType.email) {
        loginIdentifier = emailController.text.trim();
      } else {
        loginIdentifier = bankIdController.text.trim();
      }

      // Existing auth logic
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
