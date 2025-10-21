import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServicesAdminScreen extends StatelessWidget {
  const ServicesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('services').orderBy('name').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = (snapshot.data as QuerySnapshot).docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return ListTile(
                title: Text(d['name'] ?? ''),
                subtitle: Text('${d['description'] ?? ''}\n₹${(d['price'] ?? 0).toString()}'),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openForm(
                    context,
                    id: d.id,
                    name: d['name'] ?? '',
                    description: d['description'] ?? '',
                    price: (d['price'] ?? 0).toString(),
                    duration: d['durationEstimate'] ?? '',
                  ),
                ),
                onLongPress: () => FirebaseFirestore.instance.collection('services').doc(d.id).delete(),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context,
      {String? id, String name = '', String description = '', String price = '', String duration = ''}) {
    final nameCtrl = TextEditingController(text: name);
    final descCtrl = TextEditingController(text: description);
    final priceCtrl = TextEditingController(text: price);
    final durCtrl = TextEditingController(text: duration);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Add Service' : 'Edit Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price')),
              TextField(controller: durCtrl, decoration: const InputDecoration(labelText: 'Duration Estimate')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'price': double.tryParse(priceCtrl.text) ?? 0,
                'durationEstimate': durCtrl.text.trim(),
              };
              final col = FirebaseFirestore.instance.collection('services');
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
