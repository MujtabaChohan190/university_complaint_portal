/// PURPOSE: The submission form for Students.
/// Allows users to enter a title, select a category, and describe their
/// issue, which is then saved directly to the Supabase 'complaints' table.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewComplaintScreen extends StatefulWidget {
  const NewComplaintScreen({super.key});
  @override
  State<NewComplaintScreen> createState() => _NewComplaintScreenState();
}

class _NewComplaintScreenState extends State<NewComplaintScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedCatId;

  void _submit() async {
    await Supabase.instance.client.from('complaints').insert({
      'title': _titleController.text,
      'description': _descController.text,
      'category_id': _selectedCatId,
      'user_id': Supabase.instance.client.auth.currentUser!.id,
      'status': 'pending',
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Submit Complaint")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            DropdownButton<int>(
              hint: const Text("Select Category"),
              value: _selectedCatId,
              items: const [
                DropdownMenuItem(value: 1, child: Text("Cafeteria")),
                DropdownMenuItem(value: 2, child: Text("Transport")),
              ],
              onChanged: (val) => setState(() => _selectedCatId = val),
            ),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description"), maxLines: 3),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: const Text("Submit"))
          ],
        ),
      ),
    );
  }
}