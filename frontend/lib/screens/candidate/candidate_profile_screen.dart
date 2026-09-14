import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/candidate_profile_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_back_button.dart';
import '../common/login_screen.dart';

class CandidateProfileScreen extends StatefulWidget {
  const CandidateProfileScreen({super.key});

  @override
  State<CandidateProfileScreen> createState() => _CandidateProfileScreenState();
}

class _CandidateProfileScreenState extends State<CandidateProfileScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isUploadingResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profileProvider = Provider.of<CandidateProfileProvider>(context, listen: false);
      await profileProvider.fetchProfile();
      final p = profileProvider.candidateProfile;
      if (p != null) {
        _fullNameController.text = p.fullName;
        _phoneController.text = p.phone ?? '';
        _locationController.text = p.location ?? '';
        _bioController.text = p.bio ?? '';
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _pickAndUploadResume() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    setState(() => _isUploadingResume = true);

    try {
      final token = await StorageService.getToken();
      final uri = Uri.parse(ApiEndpoints.candidateResume);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      if (file.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'resume',
          file.bytes!,
          filename: file.name,
        ));
      } else if (file.path != null) {
        request.files.add(await http.MultipartFile.fromPath('resume', file.path!));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() => _isUploadingResume = false);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!mounted) return;
        Provider.of<CandidateProfileProvider>(context, listen: false).fetchProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resume PDF uploaded successfully!'),
            backgroundColor: AppColors.statusSelected,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload resume.'),
            backgroundColor: AppColors.statusRejected,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingResume = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
    final profileProvider = Provider.of<CandidateProfileProvider>(context);
    final profile = profileProvider.candidateProfile;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('My Candidate Profile & Resume'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: profileProvider.isLoading && profile == null
          ? const LoadingIndicator(message: 'Loading candidate profile...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Details Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Personal Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          const SizedBox(height: 16),
                          CustomTextField(controller: _fullNameController, label: 'Full Name', prefixIcon: Icons.person_outline),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _phoneController, label: 'Phone Number', prefixIcon: Icons.phone_outlined),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _locationController, label: 'Location', prefixIcon: Icons.location_on_outlined),
                          const SizedBox(height: 12),
                          CustomTextField(controller: _bioController, label: 'Professional Summary', maxLines: 3),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Save Profile Changes',
                            isLoading: profileProvider.isLoading,
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              final messenger = ScaffoldMessenger.of(context);
                              final ok = await profileProvider.updateProfile(
                                fullName: _fullNameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                location: _locationController.text.trim(),
                                bio: _bioController.text.trim(),
                              );
                              if (ok && mounted) {
                                authProvider.checkAuthStatus();
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Profile updated!'), backgroundColor: AppColors.statusSelected),
                                );
                              }
                            },


                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Resume Management Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.description_outlined, color: AppColors.accent),
                              SizedBox(width: 8),
                              Text('Resume Document (PDF / DOCX)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (profile?.resumeFilename != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.08),

                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.picture_as_pdf, color: AppColors.statusRejected),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          profile!.resumeFilename!,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                        Text(
                                          'URL: ${profile.resumeUrl}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          CustomButton(
                            text: profile?.resumeFilename != null ? 'Replace Resume PDF' : 'Upload Resume PDF',
                            icon: Icons.upload_file,
                            isLoading: _isUploadingResume,
                            onPressed: _pickAndUploadResume,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Education Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Education Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (profile?.education.isEmpty ?? true)
                            const Text('No education records added yet.', style: TextStyle(color: AppColors.textMuted))
                          else
                            ...profile!.education.map(
                              (edu) => ListTile(
                                leading: const Icon(Icons.school, color: AppColors.accent),
                                title: Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${edu.institution} (${edu.startYear ?? ''} - ${edu.endYear ?? 'Present'})'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logout Account Card
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
                                  'End your active session securely',
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
