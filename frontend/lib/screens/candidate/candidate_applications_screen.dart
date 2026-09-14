import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../providers/application_provider.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';

class CandidateApplicationsScreen extends StatefulWidget {
  final String? initialFilter;
  const CandidateApplicationsScreen({super.key, this.initialFilter});

  @override
  State<CandidateApplicationsScreen> createState() => _CandidateApplicationsScreenState();
}

class _CandidateApplicationsScreenState extends State<CandidateApplicationsScreen> {
  late String _selectedFilter;

  final List<String> _filters = const ['All', 'Shortlisted', 'Interview Scheduled', 'Under Review', 'Applied', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter ?? 'All';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchMyApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);

    final filteredApps = appProvider.myApplications.where((app) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Shortlisted') {
        return app.status == 'Shortlisted' || app.status == 'Interview Scheduled';
      }
      return app.status.toLowerCase() == _selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('My Applications'),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await appProvider.fetchMyApplications();
        },
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppColors.accent.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.accent : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: appProvider.isLoading
                  ? const LoadingIndicator(message: 'Fetching your applications...')
                  : filteredApps.isEmpty
                      ? EmptyState(
                          icon: Icons.assignment_late_outlined,
                          title: _selectedFilter == 'All'
                              ? 'No Applications Submitted Yet'
                              : 'No $_selectedFilter Applications',
                          description: _selectedFilter == 'All'
                              ? 'Search for active job openings and submit your first application.'
                              : 'You have no applications matching the status "$_selectedFilter".',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredApps.length,
                          itemBuilder: (context, index) {
                            final app = filteredApps[index];
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
                                            app.jobTitle,
                                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          ),
                                        ),
                                        StatusBadge(status: app.status),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      app.companyName,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Applied on: ${DateFormatter.formatDate(app.appliedAt)}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                        Text(
                                          'Application #${app.applicationId}',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent),
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
          ],
        ),
      ),
    );
  }
}
