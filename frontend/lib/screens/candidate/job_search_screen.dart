import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/job_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/app_back_button.dart';
import 'job_details_screen.dart';


class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jp = Provider.of<JobProvider>(context, listen: false);
      jp.fetchCategories();
      jp.fetchJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Search & Explore Jobs'),
      ),

      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search title, skills, location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                jobProvider.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: (val) {
                      jobProvider.setSearchQuery(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
              ],
            ),
          ),

          // Categories horizontal scroll chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: jobProvider.categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = jobProvider.selectedCategory == 'all';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: const Text('All Jobs'),
                      selected: isSelected,
                      onSelected: (_) => jobProvider.setCategoryFilter('all'),
                    ),
                  );
                }
                final cat = jobProvider.categories[index - 1];
                final isSelected = jobProvider.selectedCategory == cat.id.toString();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat.name),
                    selected: isSelected,
                    onSelected: (_) => jobProvider.setCategoryFilter(cat.id.toString()),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Jobs List
          Expanded(
            child: jobProvider.isLoading
                ? const LoadingIndicator(message: 'Searching jobs...')
                : jobProvider.jobs.isEmpty
                    ? EmptyState(
                        title: 'No Jobs Found',
                        description: 'Try adjusting your search query or clear filter selections.',
                        buttonText: 'Reset Filters',
                        onButtonPressed: () {
                          _searchController.clear();
                          jobProvider.setSearchQuery('');
                          jobProvider.setCategoryFilter('all');
                          jobProvider.setWorkModeFilter('all');
                          jobProvider.setJobTypeFilter('all');
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: jobProvider.jobs.length,
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
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Work Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['all', 'On-site', 'Remote', 'Hybrid'].map((mode) {
                      return ChoiceChip(
                        label: Text(mode == 'all' ? 'All Modes' : mode),
                        selected: jobProvider.selectedWorkMode == mode,
                        onSelected: (_) {
                          jobProvider.setWorkModeFilter(mode);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('Job Type', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['all', 'Full Time', 'Part Time', 'Internship', 'Contract'].map((type) {
                      return ChoiceChip(
                        label: Text(type == 'all' ? 'All Types' : type),
                        selected: jobProvider.selectedJobType == type,
                        onSelected: (_) {
                          jobProvider.setJobTypeFilter(type);
                          setModalState(() {});
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
