import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:karigar_woodwork/services/firestore_service.dart';
import 'package:karigar_woodwork/models/models.dart';
import 'package:karigar_woodwork/providers/cart_provider.dart';

class ShopTab extends StatelessWidget {
  const ShopTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    return StreamBuilder<List<Product>>(
      stream: service.watchProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final products = snapshot.data!;
        if (products.isEmpty) {
          return const Center(child: Text('No products yet'));
        }
        final isWide = MediaQuery.of(context).size.width > 700;
        final crossAxisCount = isWide ? 3 : 2;
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return _ProductCard(product: p);
            },
          ),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.imageUrl.isNotEmpty
                ? Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    color: Colors.brown.withOpacity(0.1),
                    child: const Center(child: Icon(Icons.chair, size: 48)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: product.stockCount <= 0
                          ? null
                          : () => cart.addProduct(product),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add'),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
