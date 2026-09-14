import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/interview_provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/job_card.dart';
import '../../widgets/common/app_back_button.dart';

import '../common/login_screen.dart';
import 'candidate_applications_screen.dart';
import 'candidate_interviews_screen.dart';
import 'job_details_screen.dart';
import 'saved_jobs_screen.dart';

class CandidateDashboardScreen extends StatefulWidget {
  const CandidateDashboardScreen({super.key});

  @override
  State<CandidateDashboardScreen> createState() => _CandidateDashboardScreenState();
}

class _CandidateDashboardScreenState extends State<CandidateDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchMyApplications();
      Provider.of<InterviewProvider>(context, listen: false).fetchMyInterviews();
      Provider.of<JobProvider>(context, listen: false).fetchJobs();
      Provider.of<JobProvider>(context, listen: false).fetchSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    final interviewProvider = Provider.of<InterviewProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);

    final user = authProvider.currentUser;
    final appsCount = appProvider.myApplications.length;
    final shortlistedCount = appProvider.myApplications.where((a) => a.status == 'Shortlisted' || a.status == 'Interview Scheduled').length;
    final upcomingInterviewsCount = interviewProvider.interviews.where((i) => i.status == 'Scheduled').length;
    final savedJobsCount = jobProvider.savedJobs.length;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, ${user?.fullName ?? "Candidate"} 👋',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Candidate Recruitment Dashboard',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedJobsScreen()));
            },
          ),
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
          await appProvider.fetchMyApplications();
          await interviewProvider.fetchMyInterviews();
          await jobProvider.fetchJobs();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Metric Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 1.5 : 1.4,
                    children: [
                      _metricCard(
                        'Applications',
                        appsCount.toString(),
                        Icons.assignment_outlined,
                        AppColors.accent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CandidateApplicationsScreen()),
                          );
                        },
                      ),
                      _metricCard(
                        'Shortlisted',
                        shortlistedCount.toString(),
                        Icons.star_outline,
                        AppColors.statusShortlisted,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CandidateApplicationsScreen(initialFilter: 'Shortlisted')),
                          );
                        },
                      ),
                      _metricCard(
                        'Interviews',
                        upcomingInterviewsCount.toString(),
                        Icons.event_available,
                        AppColors.statusInterview,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CandidateInterviewsScreen()),
                          );
                        },
                      ),
                      _metricCard(
                        'Saved Jobs',
                        savedJobsCount.toString(),
                        Icons.bookmark_border,
                        AppColors.statusUnderReview,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SavedJobsScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended Jobs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              jobProvider.isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                  : jobProvider.jobs.isEmpty
                      ? const Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text('No active job postings available right now.')),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: jobProvider.jobs.length > 5 ? 5 : jobProvider.jobs.length,
                          itemBuilder: (context, index) {
                            final job = jobProvider.jobs[index];
                            return JobCard(
                              job: job,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => JobDetailsScreen(jobId: job.id)),
                                );
                              },
                              onBookmarkTap: () {
                                jobProvider.toggleSaveJob(job.id);
                              },
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard(String title, String count, IconData icon, Color color, {VoidCallback? onTap}) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  Text(
                    count,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color.withValues(alpha: 0.6)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
