import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/job_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/app_back_button.dart';


class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleAddCategory() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isAdding = true);
    try {
      final res = await ApiService.post(ApiEndpoints.categories, {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
      });

      setState(() => _isAdding = false);
      if (!mounted) return;
      if (res['success'] == true) {
        _nameController.clear();
        _descController.clear();
        Provider.of<JobProvider>(context, listen: false).fetchCategories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job Category Created!'), backgroundColor: AppColors.statusSelected),
        );
      }
    } catch (e) {
      setState(() => _isAdding = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Manage Job Categories'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add New Job Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CustomTextField(controller: _nameController, label: 'Category Name', hint: 'DevOps & Security'),
                    const SizedBox(height: 10),
                    CustomTextField(controller: _descController, label: 'Description', hint: 'Category details...'),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Create Category',
                      isLoading: _isAdding,
                      onPressed: _handleAddCategory,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: jobProvider.categories.length,
              itemBuilder: (context, index) {
                final cat = jobProvider.categories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.category_outlined, color: AppColors.accent),
                    title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${cat.activeJobsCount} Active Jobs'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
