import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_back_button.dart';
import '../common/login_screen.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _sizeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logoUrlController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _sizeController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCompany() async {
    try {
      final res = await ApiService.get(ApiEndpoints.myCompany);
      if (res['success'] == true && res['data'] != null) {
        final c = res['data'];
        _nameController.text = c['company_name'] ?? '';
        _industryController.text = c['industry'] ?? '';
        _sizeController.text = c['company_size'] ?? '';
        _websiteController.text = c['website'] ?? '';
        _locationController.text = c['location'] ?? '';
        _descriptionController.text = c['description'] ?? '';
        _logoUrlController.text = c['logo_url'] ?? '';
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company name is required')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final res = await ApiService.post(ApiEndpoints.companies, {
        'company_name': _nameController.text.trim(),
        'industry': _industryController.text.trim(),
        'company_size': _sizeController.text.trim(),
        'website': _websiteController.text.trim(),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'logo_url': _logoUrlController.text.trim(),
      });

      setState(() => _isSaving = false);
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company profile saved successfully!'), backgroundColor: AppColors.statusSelected),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text('Are you sure you want to log out of your session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Company Profile & Branding'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: _isLoading
          ? const LoadingIndicator(message: 'Fetching company details...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Company Identity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          CustomTextField(controller: _nameController, label: 'Company Name *', hint: 'InnovateTech Inc'),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _industryController, label: 'Industry', hint: 'Software & Cloud Technology'),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _sizeController, label: 'Company Size', hint: '100-250 Employees'),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _websiteController, label: 'Official Website', hint: 'https://company.example.com'),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _locationController, label: 'Headquarters Location', hint: 'San Francisco, CA'),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _logoUrlController, label: 'Company Logo Image URL', hint: 'https://images.unsplash.com/...'),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _descriptionController, label: 'Company Overview / Description', maxLines: 4),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Save Company Profile',
                            isLoading: _isSaving,
                            onPressed: _handleSave,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Card
                  Card(
                    color: AppColors.error.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sign Out Account',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'End your active HR session securely',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Logout'),
                            onPressed: () => _confirmLogout(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
