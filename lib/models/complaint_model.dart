/// PURPOSE: The Data Blueprint.
/// Defines the 'Complaint' class to ensure the app uses consistent
/// variable names and data types when communicating with Supabase.

class Complaint {
  final int? id;
  final String userId;
  final int categoryId;
  final String title;
  final String description;
  final String status;
  final DateTime? createdAt;
  final String? studentName;
  final String? categoryName;

  Complaint({
    this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.status = 'pending',
    this.createdAt,
    this.studentName,
    this.categoryName,
  });

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      id: map['id'],
      userId: map['user_id'] ?? '',
      categoryId: map['category_id'] ?? 0,
      title: map['title'] ?? 'No Title',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      studentName: map['student_name'],
      categoryName: map['category_name'],
    );
  }
}