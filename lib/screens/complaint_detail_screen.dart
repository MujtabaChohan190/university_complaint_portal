import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ComplaintDetailScreen extends StatelessWidget {
  final Map<String, dynamic> complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  // Function to fetch feedback from the 'comments' table
  Future<Map<String, dynamic>?> _getAdminFeedback() async {
    try {
      final data = await Supabase.instance.client
          .from('comments')
          .select()
          .eq('complaint_id', complaint['id'])
          .maybeSingle(); // Returns null if no comment exists
      return data;
    } catch (e) {
      print("Error fetching feedback: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = complaint['status'].toString().toLowerCase();
    final bool isResolved = status == 'resolved';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        title: const Text("COMPLAINT DETAILS",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint['title'].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isResolved ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Description Section
            const Text("STUDENT DESCRIPTION",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              complaint['description'] ?? "No description provided.",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const Divider(height: 40, thickness: 1),

            // Admin Feedback Section (The "Magic" Part)
            FutureBuilder<Map<String, dynamic>?>(
              future: _getAdminFeedback(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // If admin hasn't commented yet
                if (!snapshot.hasData || snapshot.data == null) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "No admin feedback yet. Your complaint is being reviewed.",
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                    ),
                  );
                }

                final feedback = snapshot.data!['content'];

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF003366).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.admin_panel_settings, color: Color(0xFF003366), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "OFFICIAL ADMIN FEEDBACK",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003366),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        feedback,
                        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
                      ),
                    ],
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