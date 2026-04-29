import 'package:flutter/material.dart';
import '../services/admin_complaint_service.dart';
import '../models/complaint_model.dart';
import 'admin_action_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminComplaintService();
  late Future<List<Complaint>> _complaintsFuture;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  // This allows us to refresh the data manually or via Pull-to-Refresh
  void _loadComplaints() {
    setState(() {
      _complaintsFuture = _service.getAllComplaints();
    });
  }

  // Helper function to color-code statuses
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'in progress': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadComplaints,
          ),
        ],
      ),
      // RefreshIndicator allows you to pull down on the screen to refresh
      body: RefreshIndicator(
        onRefresh: () async => _loadComplaints(),
        child: FutureBuilder<List<Complaint>>(
          future: _complaintsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final complaints = snapshot.data ?? [];

            // If database is empty, show a friendly message instead of a white screen
            if (complaints.isEmpty) {
              return const Center(
                child: Text("No complaints submitted yet.",
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              );
            }

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final c = complaints[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(c.status),
                      child: const Icon(Icons.assignment, color: Colors.white),
                    ),
                    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("By: ${c.studentName ?? 'Unknown Student'}"),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(c.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(c.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () async {
                      // Navigate to details and refresh when coming back
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminActionScreen(complaint: c)),
                      );
                      _loadComplaints();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}