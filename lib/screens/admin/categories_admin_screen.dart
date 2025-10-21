import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesAdminScreen extends StatelessWidget {
  const CategoriesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('categories').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = (snapshot.data as QuerySnapshot).docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return ListTile(
                title: Text(d['name'] ?? ''),
                subtitle: Text(d['description'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openForm(context, id: d.id, name: d['name'] ?? '', description: d['description'] ?? ''),
                ),
                onLongPress: () => FirebaseFirestore.instance.collection('categories').doc(d.id).delete(),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {String? id, String name = '', String description = ''}) {
    final nameCtrl = TextEditingController(text: name);
    final descCtrl = TextEditingController(text: description);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final data = {'name': nameCtrl.text.trim(), 'description': descCtrl.text.trim()};
              final col = FirebaseFirestore.instance.collection('categories');
              if (id == null) {
                await col.add(data);
              } else {
                await col.doc(id).set(data, SetOptions(merge: true));
              }
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
