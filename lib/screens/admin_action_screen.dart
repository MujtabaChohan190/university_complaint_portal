/// PURPOSE: Decision-making interface for Admins.
/// Allows staff to change the status of a student's complaint (e.g.,
/// Pending to Resolved) and leave official feedback/comments.

import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../services/admin_complaint_service.dart';

class AdminActionScreen extends StatefulWidget {
  final Complaint complaint;

  const AdminActionScreen({super.key, required this.complaint});

  @override
  State<AdminActionScreen> createState() => _AdminActionScreenState();
}

class _AdminActionScreenState extends State<AdminActionScreen> {
  final _adminService = AdminComplaintService();
  final _commentController = TextEditingController();

  // Status must match your database check constraints exactly
  static const List<String> _statusOptions = [
    'pending',
    'in progress',
    'resolved',
  ];

  late String _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.complaint.status;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    // Check if any changes were actually made
    if (_selectedStatus == widget.complaint.status &&
        _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please change the status or add a comment.')),
      );
      return;
    }

    setState(() => _isUpdating = true);
    try {
      // Calls your service to update Supabase and insert a comment
      await _adminService.updateComplaintStatus(
        complaintId: widget.complaint.id!,
        newStatus: _selectedStatus,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint updated successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Returns true to trigger a list refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Action: Update Status')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.complaint.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.complaint.description, style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const Divider(height: 40),

            const Text('SET NEW STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),

            const SizedBox(height: 25),
            const Text('ADMIN FEEDBACK / COMMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type resolution steps or feedback for the student...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),
            _isUpdating
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleUpdate,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), padding: const EdgeInsets.all(15)),
                child: const Text('Update Complaint', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}