import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/app_back_button.dart';

import '../common/login_screen.dart';
import 'job_applicants_screen.dart';
import 'manage_jobs_screen.dart';
import 'post_job_screen.dart';

class RecruiterDashboardScreen extends StatefulWidget {
  const RecruiterDashboardScreen({super.key});

  @override
  State<RecruiterDashboardScreen> createState() => _RecruiterDashboardScreenState();
}

class _RecruiterDashboardScreenState extends State<RecruiterDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchMyJobs();
      Provider.of<InterviewProvider>(context, listen: false).fetchMyInterviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    final interviewProvider = Provider.of<InterviewProvider>(context);

    final user = authProvider.currentUser;
    final activeJobsCount = jobProvider.myJobs.where((j) => j.status == 'active').length;
    final totalApplicants = jobProvider.myJobs.fold<int>(0, (sum, item) => sum + item.applicantCount);
    final upcomingInterviews = interviewProvider.interviews.length;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employer Portal — ${user?.fullName ?? "Recruiter"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Recruiter & HR Management Dashboard', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await jobProvider.fetchMyJobs();
          await interviewProvider.fetchMyInterviews();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Metrics
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 2.2 : 2.6,
                    children: [
                      _metricTile(
                        'Active Jobs',
                        activeJobsCount.toString(),
                        Icons.work_outline,
                        AppColors.accent,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageJobsScreen()));
                        },
                      ),
                      _metricTile(
                        'Total Applicants',
                        totalApplicants.toString(),
                        Icons.people_outline,
                        AppColors.statusUnderReview,
                        onTap: () {
                          if (jobProvider.myJobs.isNotEmpty) {
                            final firstJob = jobProvider.myJobs.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => JobApplicantsScreen(jobId: firstJob.id, jobTitle: firstJob.title)),
                            );
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageJobsScreen()));
                          }
                        },
                      ),
                      _metricTile(
                        'Interviews Scheduled',
                        upcomingInterviews.toString(),
                        Icons.event_available,
                        AppColors.statusInterview,
                        onTap: () {
                          if (jobProvider.myJobs.isNotEmpty) {
                            final firstJob = jobProvider.myJobs.first;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => JobApplicantsScreen(jobId: firstJob.id, jobTitle: firstJob.title)),
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Posted Job Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Post New Job'),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PostJobScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              jobProvider.isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  : jobProvider.myJobs.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(28.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.work_off_outlined, size: 48, color: AppColors.textMuted),
                                  SizedBox(height: 12),
                                  Text('No Jobs Posted Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text('Click "Post New Job" above to create your first opening.', style: TextStyle(color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jobProvider.myJobs.length,
                          itemBuilder: (context, index) {
                            final job = jobProvider.myJobs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('${job.location} • ${job.jobType} • ${job.workMode}'),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${job.applicantCount} Candidate Applicants',
                                        style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => JobApplicantsScreen(jobId: job.id, jobTitle: job.title),
                                      ),
                                    );
                                  },
                                  child: const Text('Review Applicants'),
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile(String title, String val, IconData icon, Color color, {VoidCallback? onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.25), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        hoverColor: color.withValues(alpha: 0.06),
        splashColor: color.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                    Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
