import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_back_button.dart';

import '../common/login_screen.dart';
import 'manage_users_screen.dart';
import 'admin_analytics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final adminProvider = Provider.of<AdminProvider>(context);

    final stats = adminProvider.analyticsData;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Command Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('System Administrator Control Dashboard', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
          await adminProvider.fetchAnalytics();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // System Overview Cards
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
                      _adminStatTile(
                        'Candidates',
                        (stats?['total_candidates'] ?? 0).toString(),
                        Icons.person_outline,
                        AppColors.accent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen(initialRole: 'candidate'))),
                      ),
                      _adminStatTile(
                        'Recruiters',
                        (stats?['total_recruiters'] ?? 0).toString(),
                        Icons.business_center_outlined,
                        AppColors.statusShortlisted,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen(initialRole: 'recruiter'))),
                      ),
                      _adminStatTile(
                        'Companies',
                        (stats?['total_companies'] ?? 0).toString(),
                        Icons.business,
                        AppColors.statusUnderReview,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                      ),
                      _adminStatTile(
                        'Total Jobs',
                        (stats?['total_jobs'] ?? 0).toString(),
                        Icons.work_outline,
                        AppColors.statusApplied,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
                      ),
                      _adminStatTile(
                        'Applications',
                        (stats?['total_applications'] ?? 0).toString(),
                        Icons.assignment_outlined,
                        AppColors.statusInterview,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
                      ),
                      _adminStatTile(
                        'Interviews',
                        (stats?['total_interviews'] ?? 0).toString(),
                        Icons.event_available,
                        AppColors.accent,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
                      ),
                      _adminStatTile(
                        'Selected',
                        (stats?['selected_candidates'] ?? 0).toString(),
                        Icons.check_circle_outline,
                        AppColors.statusSelected,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
                      ),
                      _adminStatTile(
                        'Rejected',
                        (stats?['rejected_candidates'] ?? 0).toString(),
                        Icons.cancel_outlined,
                        AppColors.statusRejected,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen())),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('System Management Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bar_chart, size: 18),
                    label: const Text('View Interactive Analytics'),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.manage_accounts, color: AppColors.accent, size: 32),
                  title: const Text('User Role & Status Management', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Inspect candidate & recruiter profiles, toggle account active states.'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen()));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _adminStatTile(String title, String val, IconData icon, Color color, {VoidCallback? onTap}) {
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
                  Icon(icon, color: color, size: 24),
                  Text(val, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
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
