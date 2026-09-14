import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/application_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/app_back_button.dart';
import 'schedule_interview_dialog.dart';

class JobApplicantsScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobApplicantsScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchJobApplicants(widget.jobId);
    });
  }

  void _openResumeUrl(String? resumePath) async {
    final messenger = ScaffoldMessenger.of(context);
    if (resumePath == null || resumePath.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('No resume uploaded by candidate.')));
      return;
    }
    final url = '${ApiEndpoints.mediaBaseUrl}$resumePath';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      messenger.showSnackBar(SnackBar(content: Text('Resume URL: $url')));
    }
  }


  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('Applicants: ${widget.jobTitle}'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await appProvider.fetchJobApplicants(widget.jobId);
        },
        child: appProvider.isLoading
            ? const LoadingIndicator(message: 'Loading applicants...')
            : appProvider.jobApplicants.isEmpty
                ? const EmptyState(
                    title: 'No Applications Received Yet',
                    description: 'Candidates applying for this job position will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appProvider.jobApplicants.length,
                    itemBuilder: (context, index) {
                      final app = appProvider.jobApplicants[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          app.candidateName ?? 'Candidate Name',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          '${app.candidateEmail ?? ''} • ${app.candidatePhone ?? ''}',
                                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  StatusBadge(status: app.status),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (app.coverLetter != null && app.coverLetter!.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Cover Letter: "${app.coverLetter}"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13)),
                                ),
                                const SizedBox(height: 12),
                              ],
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                                    label: const Text('View Resume'),
                                    onPressed: () => _openResumeUrl(app.resumeUrl),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Applied: ${DateFormatter.formatDate(app.appliedAt)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.statusRejected),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final ok = await appProvider.updateStatus(app.applicationId, 'Rejected', jobId: widget.jobId);
                                      if (ok && mounted) {
                                        messenger.showSnackBar(const SnackBar(content: Text('Candidate Rejected.')));
                                      }
                                    },
                                    child: const Text('Reject'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.statusShortlisted),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final ok = await appProvider.updateStatus(app.applicationId, 'Shortlisted', jobId: widget.jobId);
                                      if (ok && mounted) {
                                        messenger.showSnackBar(const SnackBar(content: Text('Candidate Shortlisted!')));
                                      }
                                    },
                                    child: const Text('Shortlist'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.event, size: 16),
                                    label: const Text('Schedule Interview'),
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      final scheduled = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => ScheduleInterviewDialog(
                                          applicationId: app.applicationId,
                                          candidateName: app.candidateName ?? 'Candidate',
                                          jobTitle: widget.jobTitle,
                                        ),
                                      );
                                      if (scheduled == true && mounted) {
                                        appProvider.fetchJobApplicants(widget.jobId);
                                        messenger.showSnackBar(
                                          const SnackBar(content: Text('Interview Scheduled!'), backgroundColor: AppColors.statusSelected),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
