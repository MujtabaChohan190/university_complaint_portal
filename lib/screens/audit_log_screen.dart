/// PURPOSE: Accountability and History tracking.
/// Displays a read-only historical log of all complaints.

import 'package:flutter/material.dart';
import '../services/admin_complaint_service.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final _adminService = AdminComplaintService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        // This calls the function we just added to the service
        future: _adminService.getAuditLog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No history logs found."));
          }

          final logs = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final item = logs[index];
              final String status = (item['status'] ?? 'pending').toString().toLowerCase();

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status).withOpacity(0.1),
                    child: Icon(Icons.history_rounded, color: _getStatusColor(status), size: 20),
                  ),
                  title: Text(
                    item['title'] ?? 'Untitled Complaint',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Updated: ${item['updated_at'] ?? 'N/A'}"),
                  trailing: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'resolved') return Colors.green;
    if (status == 'in progress') return Colors.blue;
    return Colors.orange;
  }
}