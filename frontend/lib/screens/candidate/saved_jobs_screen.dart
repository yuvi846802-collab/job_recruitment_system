import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/job_card.dart';
import '../../widgets/common/loading_indicator.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchSavedJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Saved / Bookmarked Jobs'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await jobProvider.fetchSavedJobs();
        },
        child: jobProvider.isLoading
            ? const LoadingIndicator(message: 'Fetching saved jobs...')
            : jobProvider.savedJobs.isEmpty
                ? const EmptyState(
                    icon: Icons.bookmark_border,
                    title: 'No Saved Jobs Yet',
                    description: 'Bookmark jobs while searching to easily review and apply later.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobProvider.savedJobs.length,
                    itemBuilder: (context, index) {
                      final job = jobProvider.savedJobs[index];
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
      ),
    );
  }
}
