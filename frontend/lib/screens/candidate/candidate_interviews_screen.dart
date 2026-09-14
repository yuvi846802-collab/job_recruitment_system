import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/app_back_button.dart';

class CandidateInterviewsScreen extends StatefulWidget {
  const CandidateInterviewsScreen({super.key});

  @override
  State<CandidateInterviewsScreen> createState() => _CandidateInterviewsScreenState();
}

class _CandidateInterviewsScreenState extends State<CandidateInterviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InterviewProvider>(context, listen: false).fetchMyInterviews();
    });
  }

  void _openLink(String urlStr) async {
    final uri = Uri.parse(urlStr.startsWith('http') ? urlStr : 'https://$urlStr');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('My Scheduled Interviews'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await interviewProvider.fetchMyInterviews();
        },
        child: interviewProvider.isLoading
            ? const LoadingIndicator(message: 'Fetching interview schedule...')
            : interviewProvider.interviews.isEmpty
                ? const EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'No Upcoming Interviews',
                    description: 'When recruiters schedule an interview for your applications, details will appear here.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: interviewProvider.interviews.length,
                    itemBuilder: (context, index) {
                      final item = interviewProvider.interviews[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.jobTitle,
                                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  StatusBadge(status: item.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.companyName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: AppColors.accent),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Date: ${DateFormatter.formatDate(item.scheduledDate)} at ${DateFormatter.formatTime(item.scheduledTime)}',
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.videocam_outlined, size: 16, color: AppColors.accent),
                                        const SizedBox(width: 8),
                                        Text('Mode: ${item.interviewMode}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: AppColors.accent),
                                        const SizedBox(width: 8),
                                        Text('Interviewer: ${item.interviewerName}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (item.locationOrLink.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.link),
                                    label: Text('Join Meeting / Location: ${item.locationOrLink}'),
                                    onPressed: () => _openLink(item.locationOrLink),
                                  ),
                                ),
                              ],
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
