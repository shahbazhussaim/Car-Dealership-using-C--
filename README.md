# Karigar Woodwork (Flutter + Firebase)

A production-ready Flutter app for a furniture workshop: shop, services, custom orders, subscriptions, admin stock & order management, reports, user auth, and multi-device admin. Mobile and Web supported.

## Features
- Bottom navigation: Home | Shop | Services | Subscriptions | Profile
- Firebase Authentication (email/password), Firestore (products, orders, services, subscriptions), Storage (images)
- Role-based Admin Dashboard (orders, status transitions, stock decrement on confirm)
- Checkout flow creating Firestore orders
- Image uploads via Firebase Storage (web & mobile compatible)
- Reports page (examples and stubs for expansion)
- Responsive UI with warm wood theme (primary #8B4513, secondary #FAEBD7)

## Setup

1. Requirements
   - Flutter >= 3.22, Dart >= 3.3
   - Firebase project

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```
- Configure:
```bash
flutterfire configure
```
- This overwrites `lib/firebase_options.dart`. If not configured, the app shows the setup screen.

4. Run
```bash
flutter run -d chrome
```

5. Web build
```bash
flutter build web
```

## Firestore Data Models
- `users/{uid}`: `{ name, email, phone, address, role }` where `role ∈ {user, admin}`
- `products/{productId}`: `{ name, category, description, price, stockCount, imageUrl, createdAt, sku }`
- `categories/{categoryId}`: `{ name, description }`
- `orders/{orderId}`: `{ userId, items: [{productId, name, qty, price}], total, address, phone, notes, status, createdAt, updatedAt, adminNotes, assignedTo }`
- `orders/{orderId}/logs/{logId}`: `{ from, to, adminId, adminNotes, assignedTo, timestamp }`
- `services/{serviceId}`: `{ name, price, description, durationEstimate }`
- `plans/{planId}`: `{ name, priceMonthly, priceYearly, benefits, trialDays }`
- `subscriptions/{subId}`: `{ userId, planId, startDate, nextBillingDate, status, benefits }`
- `feedback/{feedbackId}`: `{ userId, orderId?, rating, message, createdAt }`

## Security Rules (sample)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isAdmin() { return isSignedIn() && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'; }

    match /products/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /orders/{orderId} {
      allow create: if isSignedIn();
      allow read: if isAdmin() || (isSignedIn() && request.auth.uid == resource.data.userId);
      allow update: if isAdmin();
    }

    match /users/{uid} {
      allow read: if isAdmin() || (isSignedIn() && uid == request.auth.uid);
      allow write: if isAdmin() || (isSignedIn() && uid == request.auth.uid);
    }

    match /subscriptions/{id} {
      allow read, write: if isAdmin() || (isSignedIn() && request.auth.uid == resource.data.userId);
    }

    match /feedback/{id} {
      allow create: if isSignedIn();
      allow read: if isAdmin();
    }
  }
}
```

## Cloud Functions (optional) - Email Notifications
- Example using SendGrid. Create `/functions/index.js`:
```javascript
const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

exports.sendStatusEmail = functions.https.onRequest(async (req, res) => {
  const { to, subject, text, html } = req.body;
  const msg = { to, from: 'no-reply@yourdomain.com', subject, text, html };
  try {
    await sgMail.send(msg);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});
```
- Env vars:
```bash
export SENDGRID_API_KEY=... # on deploy env
```
- Trigger from app by POSTing to function URL in `lib/config.dart`.

Alternative SMTP example (nodemailer):
```javascript
const nodemailer = require('nodemailer');
exports.sendStatusEmailSmtp = functions.https.onRequest(async (req, res) => {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    secure: false,
    auth: { user: process.env.SMTP_USER, pass: process.env.SMTP_PASS },
  });
  const { to, subject, text, html } = req.body;
  try {
    await transporter.sendMail({ from: 'no-reply@yourdomain.com', to, subject, text, html });
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ ok: false, error: e.message });
  }
});
```

## Seed Data
Create a simple Dart script `tool/seed.dart` and run with `dart run tool/seed.dart` after setting `GOOGLE_APPLICATION_CREDENTIALS` for admin SDK or run from a one-off Cloud Function. Alternatively add products manually in Firebase Console.

Example Firestore writes (pseudo):
- Add categories: Chairs, Tables, Cabinets
- Add products with stockCount and imageUrl
- Create user document with `role: 'admin'` for your admin uid

## Notes
- Push notifications via FCM can be added later; placeholders only
- Payment processing for subscriptions is stubbed; integrate Stripe + webhooks later
- For web, `image_picker_for_web` is used automatically
