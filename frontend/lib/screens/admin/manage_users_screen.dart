import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/app_back_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/status_badge.dart';

class ManageUsersScreen extends StatefulWidget {
  final String? initialRole;
  const ManageUsersScreen({super.key, this.initialRole});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'all';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).fetchUsers(role: _selectedRole);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Manage System Users'),
      ),

      body: Column(
        children: [
          // Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Role Filter: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 8,
                  children: ['all', 'candidate', 'recruiter', 'admin'].map((role) {
                    return ChoiceChip(
                      label: Text(role.toUpperCase()),
                      selected: _selectedRole == role,
                      onSelected: (_) {
                        setState(() => _selectedRole = role);
                        adminProvider.fetchUsers(role: role);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: adminProvider.isLoading
                ? const LoadingIndicator(message: 'Loading user accounts...')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: adminProvider.users.length,
                    itemBuilder: (context, index) {
                      final u = adminProvider.users[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: u.role == 'admin'
                                ? AppColors.statusRejected
                                : u.role == 'recruiter'
                                    ? AppColors.accent
                                    : AppColors.statusSelected,
                            child: Text(u.fullName.isNotEmpty ? u.fullName[0] : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(u.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${u.email} • Role: ${u.role.toUpperCase()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StatusBadge(status: u.isActive ? 'Active' : 'Inactive'),
                              const SizedBox(width: 8),
                              Switch(
                                value: u.isActive,
                                activeTrackColor: AppColors.statusSelected,
                                onChanged: (val) {
                                  adminProvider.toggleUserStatus(u.id, val);
                                },
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
    );
  }
}
