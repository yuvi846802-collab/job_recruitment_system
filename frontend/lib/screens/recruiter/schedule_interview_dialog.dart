import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/interview_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ScheduleInterviewDialog extends StatefulWidget {
  final int applicationId;
  final String candidateName;
  final String jobTitle;

  const ScheduleInterviewDialog({
    super.key,
    required this.applicationId,
    required this.candidateName,
    required this.jobTitle,
  });

  @override
  State<ScheduleInterviewDialog> createState() => _ScheduleInterviewDialogState();
}

class _ScheduleInterviewDialogState extends State<ScheduleInterviewDialog> {
  final _dateController = TextEditingController(text: '2026-10-15');
  final _timeController = TextEditingController(text: '14:00:00');
  final _linkController = TextEditingController(text: 'https://meet.google.com/jrms-tech-round');
  final _interviewerController = TextEditingController(text: 'Sarah Jenkins');
  final _notesController = TextEditingController(text: 'Technical interview focusing on skills and architecture.');
  String _mode = 'Online';

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _linkController.dispose();
    _interviewerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleSchedule() async {
    final interviewProvider = Provider.of<InterviewProvider>(context, listen: false);
    final success = await interviewProvider.scheduleInterview({
      'application_id': widget.applicationId,
      'scheduled_date': _dateController.text.trim(),
      'scheduled_time': _timeController.text.trim(),
      'interview_mode': _mode,
      'location_or_link': _linkController.text.trim(),
      'interviewer_name': _interviewerController.text.trim(),
      'notes': _notesController.text.trim(),
    });

    if (!mounted) return;
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    final interviewProvider = Provider.of<InterviewProvider>(context);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Schedule Interview', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Candidate: ${widget.candidateName} • ${widget.jobTitle}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(controller: _dateController, label: 'Date (YYYY-MM-DD)', hint: '2026-10-15'),
              const SizedBox(height: 10),
              CustomTextField(controller: _timeController, label: 'Time (HH:MM:SS)', hint: '14:00:00'),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: _mode,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: ['Online', 'In-Person', 'Telephonic'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (v) => setState(() => _mode = v!),
                  ),

                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(controller: _linkController, label: 'Meeting Link / Room Location'),
              const SizedBox(height: 10),
              CustomTextField(controller: _interviewerController, label: 'Interviewer Name'),
              const SizedBox(height: 10),
              CustomTextField(controller: _notesController, label: 'Notes', maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 140,
          child: CustomButton(
            text: 'Schedule',
            isLoading: interviewProvider.isLoading,
            onPressed: _handleSchedule,
          ),
        ),
      ],
    );
  }
}
