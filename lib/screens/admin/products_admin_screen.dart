import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/services/storage_service.dart';

// Admin screen: manage products (create/edit/delete, stock adjust, image upload)
class ProductsAdminScreen extends StatelessWidget {
  const ProductsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Products Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const _ProductFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Product>>(
        stream: svc.watchProducts(includeDeleted: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data!;
          if (products.isEmpty) return const Center(child: Text('No products'));
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: p.imageUrl.isEmpty
                      ? const Icon(Icons.image)
                      : Image.network(p.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                  title: Text(p.name),
                  subtitle: Text('₹${p.price} • Stock: ${p.stockCount} • SKU: ${p.sku}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => _ProductFormScreen(existing: p)),
                        );
                      } else if (v == 'delete') {
                        await svc.softDeleteProduct(p.id);
                      } else if (v == 'stock') {
                        final delta = await _askStockDelta(context);
                        if (delta != null) await svc.updateStock(p.id, delta);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'stock', child: Text('Adjust Stock')),
                      PopupMenuItem(value: 'delete', child: Text('Delete (soft)')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<int?> _askStockDelta(BuildContext context) async {
    final ctrl = TextEditingController();
    final delta = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adjust Stock'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Delta (+/-)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
              child: const Text('Apply')),
        ],
      ),
    );
    return delta;
  }
}

class _ProductFormScreen extends StatefulWidget {
  final Product? existing;
  const _ProductFormScreen({this.existing});

  @override
  State<_ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<_ProductFormScreen> {
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  final _sku = TextEditingController();
  String _imageUrl = '';
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _name.text = p.name;
      _category.text = p.category;
      _description.text = p.description;
      _price.text = p.price.toString();
      _stock.text = p.stockCount.toString();
      _sku.text = p.sku;
      _imageUrl = p.imageUrl;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _sku.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final url = await StorageService().uploadImage(pathPrefix: 'products');
      setState(() => _imageUrl = url);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Name required');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final data = {
        'name': _name.text.trim(),
        'category': _category.text.trim(),
        'description': _description.text.trim(),
        'price': double.tryParse(_price.text) ?? 0,
        'stockCount': int.tryParse(_stock.text) ?? 0,
        'imageUrl': _imageUrl,
        'createdAt': widget.existing == null ? Timestamp.now() : FieldValue.serverTimestamp(),
        'sku': _sku.text.trim(),
      };
      final db = FirebaseFirestore.instance;
      if (widget.existing == null) {
        await db.collection('products').add(data);
      } else {
        await db.collection('products').doc(widget.existing!.id).set(data, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'Add Product' : 'Edit Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 8),
          TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category')),
          const SizedBox(height: 8),
          TextField(controller: _description, decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 8),
          TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock Count'), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: _sku, decoration: const InputDecoration(labelText: 'SKU')),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.upload), label: const Text('Upload Image')),
              const SizedBox(width: 12),
              if (_imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(_imageUrl, height: 64, width: 64, fit: BoxFit.cover),
                )
            ],
          ),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save'),
          )
        ],
      ),
    );
  }
}
