import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlansAdminScreen extends StatelessWidget {
  const PlansAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plans')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('plans').orderBy('priceMonthly').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = (snapshot.data as QuerySnapshot).docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index];
              return ListTile(
                title: Text(d['name'] ?? ''),
                subtitle: Text('₹${(d['priceMonthly'] ?? 0).toString()}/mo • ₹${(d['priceYearly'] ?? 0).toString()}/yr'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openForm(
                    context,
                    id: d.id,
                    name: d['name'] ?? '',
                    priceMonthly: (d['priceMonthly'] ?? 0).toString(),
                    priceYearly: (d['priceYearly'] ?? 0).toString(),
                    benefits: (d['benefits'] as List?)?.join(', ') ?? '',
                    trialDays: (d['trialDays'] ?? 0).toString(),
                  ),
                ),
                onLongPress: () => FirebaseFirestore.instance.collection('plans').doc(d.id).delete(),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context,
      {String? id,
      String name = '',
      String priceMonthly = '',
      String priceYearly = '',
      String benefits = '',
      String trialDays = ''}) {
    final nameCtrl = TextEditingController(text: name);
    final pmCtrl = TextEditingController(text: priceMonthly);
    final pyCtrl = TextEditingController(text: priceYearly);
    final benCtrl = TextEditingController(text: benefits);
    final tdCtrl = TextEditingController(text: trialDays);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Add Plan' : 'Edit Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: pmCtrl, decoration: const InputDecoration(labelText: 'Price Monthly')),
              TextField(controller: pyCtrl, decoration: const InputDecoration(labelText: 'Price Yearly')),
              TextField(controller: benCtrl, decoration: const InputDecoration(labelText: 'Benefits (comma-separated)')),
              TextField(controller: tdCtrl, decoration: const InputDecoration(labelText: 'Trial Days')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final data = {
                'name': nameCtrl.text.trim(),
                'priceMonthly': double.tryParse(pmCtrl.text) ?? 0,
                'priceYearly': double.tryParse(pyCtrl.text) ?? 0,
                'benefits': benCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
                'trialDays': int.tryParse(tdCtrl.text) ?? 0,
              };
              final col = FirebaseFirestore.instance.collection('plans');
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
