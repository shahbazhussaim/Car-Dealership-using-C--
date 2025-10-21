import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/services/email_service.dart';

// Admin: Manage technicians (CRUD) and view assigned orders
class TechniciansAdminScreen extends StatelessWidget {
  const TechniciansAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technicians')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('technicians').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = (snapshot.data as QuerySnapshot).docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(d['name'] ?? ''),
                  subtitle: Text('${d['email'] ?? ''} • ${d['phone'] ?? ''}\nSkills: ${(d['skills'] as List?)?.join(', ') ?? ''}'),
                  isThreeLine: true,
                  trailing: Switch(
                    value: (d['available'] ?? true) as bool,
                    onChanged: (v) => FirebaseFirestore.instance
                        .collection('technicians')
                        .doc(d.id)
                        .set({'available': v, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true)),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => _TechnicianDetail(techId: d.id)),
                  ),
                  onLongPress: () => FirebaseFirestore.instance
                      .collection('technicians')
                      .doc(d.id)
                      .set({'deleted': true}, SetOptions(merge: true)),
                  leading: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _openForm(
                      context,
                      id: d.id,
                      name: d['name'] ?? '',
                      email: d['email'] ?? '',
                      phone: d['phone'] ?? '',
                      skills: (d['skills'] as List?)?.join(', ') ?? '',
                      available: (d['available'] ?? true) as bool,
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

  void _openForm(BuildContext context,
      {String? id, String name = '', String email = '', String phone = '', String skills = '', bool available = true}) {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);
    final phoneCtrl = TextEditingController(text: phone);
    final skillsCtrl = TextEditingController(text: skills);
    bool avail = available;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(id == null ? 'Add Technician' : 'Edit Technician'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                TextField(controller: skillsCtrl, decoration: const InputDecoration(labelText: 'Skills (comma-separated)')),
                Row(children: [
                  const Text('Available'),
                  const SizedBox(width: 8),
                  Switch(value: avail, onChanged: (v) => setState(() => avail = v)),
                ])
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final data = {
                  'name': nameCtrl.text.trim(),
                  'email': emailCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                  'skills': skillsCtrl.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'available': avail,
                  'updatedAt': FieldValue.serverTimestamp(),
                  if (id == null) 'createdAt': FieldValue.serverTimestamp(),
                };
                final col = FirebaseFirestore.instance.collection('technicians');
                if (id == null) {
                  await col.add(data);
                } else {
                  await col.doc(id).set(data, SetOptions(merge: true));
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      }),
    );
  }
}

class _TechnicianDetail extends StatelessWidget {
  final String techId;
  const _TechnicianDetail({required this.techId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Technician Details')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').where('assignedTo', isEqualTo: techId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = (snapshot.data as QuerySnapshot).docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return ListTile(
                title: Text('Order #${d.id}'),
                subtitle: Text('Status: ${d['status']}  •  Total: ₹${d['total']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () async {
                    final email = await _getTechEmail(techId);
                    if (email != null && email.isNotEmpty) {
                      final err = await EmailService.sendTechnicianAssigned(
                        technicianEmail: email,
                        orderId: d.id,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err == null ? 'Email sent' : 'Email failed: $err')));
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<String?> _getTechEmail(String id) async {
    final doc = await FirebaseFirestore.instance.collection('technicians').doc(id).get();
    return (doc.data()?['email'] as String?) ?? '';
  }
}
