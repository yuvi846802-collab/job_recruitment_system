import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_snackbar.dart';
import '../candidate/candidate_main_layout.dart';
import '../recruiter/recruiter_main_layout.dart';
import '../admin/admin_main_layout.dart';
import 'register_candidate_screen.dart';
import 'register_recruiter_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final role = authProvider.userRole.toLowerCase();
      if (role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AdminMainLayout()),
        );
      } else if (role == 'recruiter' || role == 'hr') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RecruiterMainLayout()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CandidateMainLayout()),
        );
      }
    } else {
      AppSnackbar.showError(context, authProvider.errorMessage ?? 'Invalid email or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B52E1), // Royal Blue
              Color(0xFF5B3CC4), // Deep Purple
              Color(0xFF8638C6), // Electric Purple
            ],
          ),
        ),
        child: Stack(
          children: [
            // Soft Background Glowing Overlay Orbs (Matching Design Picture)
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.pinkAccent.withValues(alpha: 0.25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withValues(alpha: 0.25),
                      blurRadius: 90,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purpleAccent.withValues(alpha: 0.25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withValues(alpha: 0.25),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Area
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildMemberLoginCard(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 💳 Member Login Card (Exact UI Matching Picture)
  Widget _buildMemberLoginCard() {
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Top White Circle Avatar Badge
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.5),
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 58, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Title Text: "Member Login"
          const Text(
            'Member Login',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 36),

          // 3. Input 1: "Username" (Pill shape, Person Icon, Accepts Email)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Username',
                hintStyle: TextStyle(color: Color(0xFF8898AA), fontSize: 17, fontWeight: FontWeight.w400),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 20, right: 14),
                  child: Icon(Icons.person, color: Color(0xFF3B52E1), size: 26),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Username (Email) is required';
                if (!val.contains('@')) return 'Enter a valid email address';
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // 4. Input 2: Password Field (Pill shape, Lock Icon)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600, fontSize: 16),
              decoration: InputDecoration(
                hintText: '••••••••••••',
                hintStyle: const TextStyle(color: Color(0xFF8898AA), fontSize: 18, letterSpacing: 2),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 20, right: 14),
                  child: Icon(Icons.lock, color: Color(0xFF3B52E1), size: 26),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: const Color(0xFF8898AA),
                      size: 22,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Password is required';
                return null;
              },
            ),
          ),
          const SizedBox(height: 18),

          // 5. Options Row: "Remember me" & "Forgot Password?"
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4,
            children: [
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _rememberMe ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 6. Pill-shaped White Outline Login Button
          Container(
            width: 180,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 2),
              color: Colors.white.withValues(alpha: 0.12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: authProvider.isLoading ? null : _handleLogin,
                child: Center(
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // 7. Footer: "Not a member?" & White Pill Button "Create an account"
          const Text(
            'Not a member?',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3B52E1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
              elevation: 4,
            ),
            onPressed: () => _showRegisterChoiceDialog(context),
            child: const Text(
              'Create an account',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3B52E1)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterChoiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose Account Type'),
        content: const Text('Would you like to register as a User (Candidate seeking jobs) or HR (Recruiter posting jobs)?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterCandidateScreen()));
            },
            child: const Text('As User / Candidate'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterRecruiterScreen()));
            },
            child: const Text('As HR / Recruiter'),
          ),
        ],
      ),
    );
  }
}
