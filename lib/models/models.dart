import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int stockCount;
  final String imageUrl;
  final Timestamp createdAt;
  final String sku;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.stockCount,
    required this.imageUrl,
    required this.createdAt,
    required this.sku,
  });

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Product(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      stockCount: (d['stockCount'] ?? 0) as int,
      imageUrl: d['imageUrl'] ?? '',
      createdAt: d['createdAt'] ?? Timestamp.now(),
      sku: d['sku'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'stockCount': stockCount,
        'imageUrl': imageUrl,
        'createdAt': createdAt,
        'sku': sku,
      };
}

class Category {
  final String id;
  final String name;
  final String description;

  Category({required this.id, required this.name, required this.description});

  factory Category.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Category(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
      };
}

class OrderItem {
  final String productId;
  final String name;
  final int qty;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> d) => OrderItem(
        productId: d['productId'] ?? '',
        name: d['name'] ?? '',
        qty: (d['qty'] ?? 0) as int,
        price: (d['price'] ?? 0).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'name': name,
        'qty': qty,
        'price': price,
      };
}

enum OrderStatus {
  newOrder,
  confirmed,
  inProgress,
  awaitingShipment,
  delivered,
  cancelled,
  returnRequested,
  returned,
}

OrderStatus parseOrderStatus(String s) {
  switch (s) {
    case 'NEW':
      return OrderStatus.newOrder;
    case 'CONFIRMED':
      return OrderStatus.confirmed;
    case 'IN_PROGRESS':
      return OrderStatus.inProgress;
    case 'AWAITING_SHIPMENT':
      return OrderStatus.awaitingShipment;
    case 'DELIVERED':
    case 'COMPLETED':
      return OrderStatus.delivered;
    case 'CANCELLED':
      return OrderStatus.cancelled;
    case 'RETURN_REQUESTED':
      return OrderStatus.returnRequested;
    case 'RETURNED':
      return OrderStatus.returned;
    default:
      return OrderStatus.newOrder;
  }
}

String orderStatusToString(OrderStatus s) {
  switch (s) {
    case OrderStatus.newOrder:
      return 'NEW';
    case OrderStatus.confirmed:
      return 'CONFIRMED';
    case OrderStatus.inProgress:
      return 'IN_PROGRESS';
    case OrderStatus.awaitingShipment:
      return 'AWAITING_SHIPMENT';
    case OrderStatus.delivered:
      return 'DELIVERED';
    case OrderStatus.cancelled:
      return 'CANCELLED';
    case OrderStatus.returnRequested:
      return 'RETURN_REQUESTED';
    case OrderStatus.returned:
      return 'RETURNED';
  }
}

class Order {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double total;
  final String address;
  final String phone;
  final String? notes;
  final OrderStatus status;
  final Timestamp createdAt;
  final Timestamp? updatedAt;
  final String? adminNotes;
  final String? assignedTo;
  final String? paymentStatus; // UNPAID, PAID, REFUNDED
  final List<String>? images; // optional image URLs for order

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.address,
    required this.phone,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.adminNotes,
    this.assignedTo,
    this.paymentStatus,
    this.images,
  });

  factory Order.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Order(
      id: doc.id,
      userId: d['userId'] ?? '',
      items: (d['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      total: (d['total'] ?? 0).toDouble(),
      address: d['address'] ?? '',
      phone: d['phone'] ?? '',
      notes: d['notes'],
      status: parseOrderStatus(d['status'] ?? 'NEW'),
      createdAt: d['createdAt'] ?? Timestamp.now(),
      updatedAt: d['updatedAt'],
      adminNotes: d['adminNotes'],
      assignedTo: d['assignedTo'],
      paymentStatus: d['paymentStatus'],
      images: (d['images'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'items': items.map((e) => e.toMap()).toList(),
        'total': total,
        'address': address,
        'phone': phone,
        'notes': notes,
        'status': orderStatusToString(status),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'adminNotes': adminNotes,
        'assignedTo': assignedTo,
        if (paymentStatus != null) 'paymentStatus': paymentStatus,
        if (images != null) 'images': images,
      };
}

class ServiceItem {
  final String id;
  final String name;
  final double price;
  final String description;
  final String durationEstimate;

  ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.durationEstimate,
  });

  factory ServiceItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return ServiceItem(
      id: doc.id,
      name: d['name'] ?? '',
      price: (d['price'] ?? 0).toDouble(),
      description: d['description'] ?? '',
      durationEstimate: d['durationEstimate'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'price': price,
        'description': description,
        'durationEstimate': durationEstimate,
      };
}

class Plan {
  final String id;
  final String name;
  final double priceMonthly;
  final double priceYearly;
  final List<String> benefits;
  final int trialDays;

  Plan({
    required this.id,
    required this.name,
    required this.priceMonthly,
    required this.priceYearly,
    required this.benefits,
    required this.trialDays,
  });

  factory Plan.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Plan(
      id: doc.id,
      name: d['name'] ?? '',
      priceMonthly: (d['priceMonthly'] ?? 0).toDouble(),
      priceYearly: (d['priceYearly'] ?? 0).toDouble(),
      benefits: (d['benefits'] as List<dynamic>? ?? []).cast<String>(),
      trialDays: (d['trialDays'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'priceMonthly': priceMonthly,
        'priceYearly': priceYearly,
        'benefits': benefits,
        'trialDays': trialDays,
      };
}

enum SubscriptionStatus { trial, active, pastDue, cancelled, expired }

SubscriptionStatus parseSubStatus(String s) {
  switch (s) {
    case 'TRIAL':
      return SubscriptionStatus.trial;
    case 'ACTIVE':
      return SubscriptionStatus.active;
    case 'PAST_DUE':
      return SubscriptionStatus.pastDue;
    case 'CANCELLED':
      return SubscriptionStatus.cancelled;
    case 'EXPIRED':
      return SubscriptionStatus.expired;
    default:
      return SubscriptionStatus.trial;
  }
}

String subStatusToString(SubscriptionStatus s) {
  switch (s) {
    case SubscriptionStatus.trial:
      return 'TRIAL';
    case SubscriptionStatus.active:
      return 'ACTIVE';
    case SubscriptionStatus.pastDue:
      return 'PAST_DUE';
    case SubscriptionStatus.cancelled:
      return 'CANCELLED';
    case SubscriptionStatus.expired:
      return 'EXPIRED';
  }
}

class Subscription {
  final String id;
  final String userId;
  final String planId;
  final Timestamp startDate;
  final Timestamp nextBillingDate;
  final SubscriptionStatus status;
  final List<String> benefits;

  Subscription({
    required this.id,
    required this.userId,
    required this.planId,
    required this.startDate,
    required this.nextBillingDate,
    required this.status,
    required this.benefits,
  });

  factory Subscription.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Subscription(
      id: doc.id,
      userId: d['userId'] ?? '',
      planId: d['planId'] ?? '',
      startDate: d['startDate'] ?? Timestamp.now(),
      nextBillingDate: d['nextBillingDate'] ?? Timestamp.now(),
      status: parseSubStatus(d['status'] ?? 'TRIAL'),
      benefits: (d['benefits'] as List<dynamic>? ?? []).cast<String>(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'planId': planId,
        'startDate': startDate,
        'nextBillingDate': nextBillingDate,
        'status': subStatusToString(status),
        'benefits': benefits,
      };
}

class FeedbackEntry {
  final String id;
  final String userId;
  final String? orderId;
  final int rating;
  final String message;
  final Timestamp createdAt;

  FeedbackEntry({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.rating,
    required this.message,
    required this.createdAt,
  });

  factory FeedbackEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return FeedbackEntry(
      id: doc.id,
      userId: d['userId'] ?? '',
      orderId: d['orderId'],
      rating: (d['rating'] ?? 0) as int,
      message: d['message'] ?? '',
      createdAt: d['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'orderId': orderId,
        'rating': rating,
        'message': message,
        'createdAt': createdAt,
      };
}
