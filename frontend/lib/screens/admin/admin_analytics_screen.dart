import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/app_back_button.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final stats = adminProvider.analyticsData;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Interactive Recruitment Analytics'),
      ),

      body: adminProvider.isLoading || stats == null
          ? const LoadingIndicator(message: 'Building visual charts...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application Status Pie Chart Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Applications Breakdown by Lifecycle Status',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 4,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    color: AppColors.statusApplied,
                                    value: 4,
                                    title: 'Applied',
                                    radius: 50,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.statusShortlisted,
                                    value: 2,
                                    title: 'Shortlisted',
                                    radius: 55,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.statusInterview,
                                    value: 3,
                                    title: 'Interview',
                                    radius: 50,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.statusSelected,
                                    value: 1,
                                    title: 'Selected',
                                    radius: 50,
                                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _LegendTile(color: AppColors.statusApplied, label: 'Applied'),
                              _LegendTile(color: AppColors.statusShortlisted, label: 'Shortlisted'),
                              _LegendTile(color: AppColors.statusInterview, label: 'Interview Scheduled'),
                              _LegendTile(color: AppColors.statusSelected, label: 'Selected'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Jobs by Category Bar Chart Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Job Distribution Across Categories',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 220,
                            child: BarChart(
                              BarChartData(
                                borderData: FlBorderData(show: false),
                                gridData: const FlGridData(show: false),
                                titlesData: const FlTitlesData(
                                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                barGroups: [
                                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: AppColors.accent, width: 24, borderRadius: BorderRadius.circular(6))]),
                                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2, color: AppColors.statusShortlisted, width: 24, borderRadius: BorderRadius.circular(6))]),
                                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1, color: AppColors.statusUnderReview, width: 24, borderRadius: BorderRadius.circular(6))]),
                                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 2, color: AppColors.statusSelected, width: 24, borderRadius: BorderRadius.circular(6))]),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LegendTile extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendTile({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
