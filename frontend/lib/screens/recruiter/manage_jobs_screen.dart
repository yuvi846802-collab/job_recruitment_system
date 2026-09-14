import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';
import 'job_applicants_screen.dart';

class ManageJobsScreen extends StatefulWidget {
  const ManageJobsScreen({super.key});

  @override
  State<ManageJobsScreen> createState() => _ManageJobsScreenState();
}

class _ManageJobsScreenState extends State<ManageJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchMyJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Manage Posted Jobs'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await jobProvider.fetchMyJobs();
        },
        child: jobProvider.isLoading
            ? const LoadingIndicator(message: 'Fetching posted jobs...')
            : jobProvider.myJobs.isEmpty
                ? const EmptyState(
                    title: 'No Active Jobs Found',
                    description: 'Create your first job posting from the Post Job tab.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobProvider.myJobs.length,
                    itemBuilder: (context, index) {
                      final job = jobProvider.myJobs[index];
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
                                    child: Text(job.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  StatusBadge(status: job.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${job.location} • ${job.jobType} • ${job.workMode}', style: const TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 12),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${job.applicantCount} Total Applicants', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JobApplicantsScreen(jobId: job.id, jobTitle: job.title),
                                        ),
                                      );
                                    },
                                    child: const Text('View Applicants'),
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
