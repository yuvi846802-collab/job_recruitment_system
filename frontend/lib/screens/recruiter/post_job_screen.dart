import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/job_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/app_back_button.dart';


class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController(text: '80000');
  final _salaryMaxController = TextEditingController(text: '120000');
  final _expController = TextEditingController(text: '2');
  final _openingsController = TextEditingController(text: '1');
  final _descriptionController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _requirementsController = TextEditingController();

  int _selectedCategoryId = 1;
  String _selectedJobType = 'Full Time';
  String _selectedWorkMode = 'On-site';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _expController.dispose();
    _openingsController.dispose();
    _descriptionController.dispose();
    _responsibilitiesController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _handlePostJob() async {
    if (!_formKey.currentState!.validate()) return;

    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final success = await jobProvider.createJob({
      'title': _titleController.text.trim(),
      'category_id': _selectedCategoryId,
      'location': _locationController.text.trim(),
      'salary_min': double.tryParse(_salaryMinController.text) ?? 0,
      'salary_max': double.tryParse(_salaryMaxController.text) ?? 0,
      'experience_years': int.tryParse(_expController.text) ?? 0,
      'openings': int.tryParse(_openingsController.text) ?? 1,
      'job_type': _selectedJobType,
      'work_mode': _selectedWorkMode,
      'description': _descriptionController.text.trim(),
      'responsibilities': _responsibilitiesController.text.trim(),
      'requirements': _requirementsController.text.trim(),
    });

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job posted successfully!'), backgroundColor: AppColors.statusSelected),
      );
      _titleController.clear();
      _descriptionController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jobProvider.errorMessage ?? 'Failed to post job.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Post New Job Opening'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Job Post Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _titleController,
                    label: 'Job Title *',
                    hint: 'e.g. Senior Flutter Developer',
                    validator: (v) => v == null || v.isEmpty ? 'Job title is required' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Job Category *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int>(
                    initialValue: jobProvider.categories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : (jobProvider.categories.isNotEmpty ? jobProvider.categories.first.id : 1),
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                    items: jobProvider.categories
                        .map((cat) => DropdownMenuItem<int>(value: cat.id, child: Text(cat.name)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategoryId = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location *',
                    hint: 'San Francisco, CA',
                    validator: (v) => v == null || v.isEmpty ? 'Location is required' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _salaryMinController,
                          label: 'Min Salary (\$) *',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          controller: _salaryMaxController,
                          label: 'Max Salary (\$) *',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Job Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedJobType,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                              items: ['Full Time', 'Part Time', 'Internship', 'Contract']
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedJobType = v!),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Work Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedWorkMode,
                              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                              items: ['On-site', 'Remote', 'Hybrid']
                                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedWorkMode = v!),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Job Description *',
                    hint: 'Provide job description & goals...',
                    maxLines: 4,
                    validator: (v) => v == null || v.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _responsibilitiesController,
                    label: 'Key Responsibilities',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _requirementsController,
                    label: 'Requirements & Qualifications',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Publish Job Posting',
                    isLoading: jobProvider.isLoading,
                    onPressed: _handlePostJob,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
