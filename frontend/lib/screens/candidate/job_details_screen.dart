import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';

class JobDetailsScreen extends StatefulWidget {
  final int jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final _coverLetterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchJobDetails(widget.jobId);
    });
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  void _showApplyModal(BuildContext context, int jobId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Submit Application',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Include a cover letter to introduce yourself to the recruiter.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _coverLetterController,
                label: 'Cover Letter (Optional)',
                hint: 'Explain why you are the best candidate for this position...',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Consumer<ApplicationProvider>(
                builder: (context, ap, _) {
                  return CustomButton(
                    text: 'Confirm & Submit Application',
                    isLoading: ap.isLoading,
                    onPressed: () async {
                      final jobProvider = Provider.of<JobProvider>(context, listen: false);
                      final success = await ap.applyForJob(jobId, _coverLetterController.text.trim());
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (success) {
                        jobProvider.fetchJobDetails(jobId);
                        AppSnackbar.showSuccess(ctx, 'Application submitted successfully!');
                      } else {
                        AppSnackbar.showError(ctx, ap.errorMessage ?? 'Failed to apply.');
                      }
                    },


                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final job = jobProvider.selectedJob;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Job Detail Specs'),
        actions: [

          if (job != null && authProvider.userRole == 'candidate')
            IconButton(
              icon: Icon(job.isSaved ? Icons.bookmark : Icons.bookmark_border, color: job.isSaved ? AppColors.accent : null),
              onPressed: () {
                jobProvider.toggleSaveJob(job.id);
              },
            ),
        ],
      ),
      body: jobProvider.isLoading || job == null
          ? const LoadingIndicator(message: 'Loading job specifications...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company & Title Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),

                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Text(
                                    job.companyName.isNotEmpty ? job.companyName[0].toUpperCase() : 'C',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job.title,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      job.companyName,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('SALARY RANGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${DateFormatter.formatCurrency(job.salaryMin)} - ${DateFormatter.formatCurrency(job.salaryMax)}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent),
                                  ),
                                ],
                              ),
                              StatusBadge(status: job.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Overview Highlights
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 12,
                        children: [
                          _specTile(Icons.location_on_outlined, 'Location', job.location),
                          _specTile(Icons.work_outline, 'Job Type', job.jobType),
                          _specTile(Icons.laptop_mac_outlined, 'Work Mode', job.workMode),
                          _specTile(Icons.business_center_outlined, 'Experience', '${job.experienceYears}+ years'),
                          _specTile(Icons.people_outline, 'Openings', '${job.openings} positions'),
                          if (job.deadline != null)
                            _specTile(Icons.calendar_today_outlined, 'Deadline', DateFormatter.formatDate(job.deadline)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Job Description
                  const Text('Job Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text(job.description, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),

                  if (job.responsibilities != null && job.responsibilities!.isNotEmpty) ...[
                    const Text('Responsibilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(job.responsibilities!, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                  ],

                  if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                    const Text('Requirements & Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Text(job.requirements!, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: job == null || authProvider.userRole != 'candidate'
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                child: job.isApplied
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusSelected,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('APPLICATION SUBMITTED'),
                      )
                    : CustomButton(
                        text: 'APPLY NOW',
                        icon: Icons.send_rounded,
                        onPressed: () => _showApplyModal(context, job.id),
                      ),
              ),
            ),
    );
  }

  Widget _specTile(IconData icon, String title, String val) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
      ],
    );
  }
}
