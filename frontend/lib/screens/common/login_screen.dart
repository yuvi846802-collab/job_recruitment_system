import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
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
  final _emailController = TextEditingController(text: 'user@jrms.local');
  final _passwordController = TextEditingController(text: 'User@JRMS2026');
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String _selectedRole = 'user'; // user, hr, admin

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _populateCredentials(String roleKey, String email, String password) {
    setState(() {
      _selectedRole = roleKey;
      _emailController.text = email;
      _passwordController.text = password;
    });
    // NOTE: Intentionally populates fields ONLY without auto-submitting
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
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: isDesktop ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: isDesktop ? _buildSplitDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  /// 🖥️ Split Desktop / Laptop Layout
  Widget _buildSplitDesktopLayout() {
    return Row(
      children: [
        // Left Side: Brand & Recruitment Banner Illustration
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(48.0),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                  Color(0xFF1E1B4B),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.work_history_rounded, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'JRMS PLATFORM',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'Job Recruitment Management System',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Hero Vector Illustration Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.hub_rounded, size: 48, color: AppColors.secondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Connecting Top Talent with Industry Leaders',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enterprise-grade recruitment portal with real-time PostgreSQL database synchronization, role-based controls, and seamless candidate-HR workflow.',
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.75), height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Feature Highlights
                _featureItem(Icons.verified_user_rounded, 'Real Supabase PostgreSQL Database Authentication'),
                const SizedBox(height: 14),
                _featureItem(Icons.badge_rounded, '3 Distinct Roles: Admin, HR, and User (Job Seeker)'),
                const SizedBox(height: 14),
                _featureItem(Icons.security_rounded, 'Bcrypt Hashed Security & Role-Based Authorization'),
              ],
            ),
          ),
        ),

        // Right Side: Sign In Card
        Expanded(
          flex: 4,
          child: Container(
            color: AppColors.background,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _buildLoginFormCard(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 📱 Mobile & Tablet Single Column Layout
  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _buildLoginFormCard(),
        ),
      ),
    );
  }

  /// 💳 Login Form Card (Shared between layouts)
  Widget _buildLoginFormCard() {
    final authProvider = Provider.of<AuthProvider>(context);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lock_open_rounded, color: AppColors.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Sign in to continue to JRMS',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Role Quick Fill Selection Tabs
              const Text(
                'Select Role to Populate Fields',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    _roleTabItem('user', 'USER', Icons.person_outline, 'user@jrms.local', 'User@JRMS2026'),
                    _roleTabItem('hr', 'HR', Icons.business_center_outlined, 'hr@jrms.local', 'HR@JRMS2026'),
                    _roleTabItem('admin', 'ADMIN', Icons.admin_panel_settings_outlined, 'admin@jrms.local', 'Admin@JRMS2026'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Email Input Field
              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Email address is required';
                  if (!val.contains('@')) return 'Enter a valid email address';
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Password Input Field
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Password is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Remember Me & Forgot Password Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.accent,
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember Me',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign In Action Button (Authenticates against real backend API)
              CustomButton(
                text: 'Sign In to ${_selectedRole.toUpperCase()}',
                isLoading: authProvider.isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 24),

              // Development Demo Credentials Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.developer_mode_rounded, size: 16, color: AppColors.accent),
                        SizedBox(width: 6),
                        Text(
                          'DEVELOPMENT ACCOUNTS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _credentialButton('ADMIN', 'admin@jrms.local', 'Admin@JRMS2026'),
                    _credentialButton('HR', 'hr@jrms.local', 'HR@JRMS2026'),
                    _credentialButton('USER', 'user@jrms.local', 'User@JRMS2026'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Registration Link Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => _showRegisterChoiceDialog(context),
                    child: const Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _roleTabItem(String roleKey, String label, IconData icon, String fillEmail, String fillPassword) {
    final isSelected = _selectedRole == roleKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => _populateCredentials(roleKey, fillEmail, fillPassword),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _credentialButton(String roleLabel, String email, String password) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: InkWell(
        onTap: () => _populateCredentials(roleLabel.toLowerCase(), email, password),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$roleLabel:', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(email, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary)),
            ],
          ),
        ),
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
