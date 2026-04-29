/// PURPOSE: Data Access Object (DAO) for Admin functions.
/// Contains the backend logic for fetching stats, updating statuses,
/// and interacting with the database.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/complaint_model.dart';

class AdminComplaintService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Get Stats for Dashboard
  Future<Map<String, int>> getComplaintStats() async {
    try {
      final response = await _supabase.from('complaints').select('status');
      final List data = response as List;
      int pending = 0, inProgress = 0, resolved = 0;

      for (final row in data) {
        if (row['status'] == 'pending') pending++;
        else if (row['status'] == 'in progress') inProgress++;
        else if (row['status'] == 'resolved') resolved++;
      }
      return {'pending': pending, 'in_progress': inProgress, 'resolved': resolved};
    } catch (e) {
      return {'pending': 0, 'in_progress': 0, 'resolved': 0};
    }
  }

  // 2. Get All Complaints (Used in Dashboard)
  Future<List<Complaint>> getAllComplaints({String? categoryName}) async {
    try {
      // Using 'complaints' table directly to ensure it works even without the View
      var query = _supabase.from('complaints').select();

      final List response = await query.order('created_at', ascending: false);
      return response.map((json) => Complaint.fromMap(json)).toList();
    } catch (e) {
      print("Error fetching complaints: $e");
      return [];
    }
  }

  // 3. Update Status and Add Comment
  Future<void> updateComplaintStatus({required int complaintId, required String newStatus, String? comment}) async {
    await _supabase.from('complaints').update({'status': newStatus}).eq('id', complaintId);

    if (comment != null && comment.trim().isNotEmpty) {
      await _supabase.from('comments').insert({
        'complaint_id': complaintId,
        'user_id': _supabase.auth.currentUser?.id,
        'content': comment.trim(),
      });
    }
  }

  Future<List<Map<String, dynamic>>> getAuditLog() async {
    try {
      final response = await _supabase
          .from('complaints')
          .select('title, status, updated_at, user_id')
          .order('updated_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print("Audit Log Error: $e");
      return [];
    }
  }
}