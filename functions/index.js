// Firebase Cloud Function: send templated email via SendGrid
// Deploy with: firebase deploy --only functions

const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');

sgMail.setApiKey(process.env.SENDGRID_API_KEY || '');
const FROM = process.env.SENDGRID_FROM || 'no-reply@example.com';

function renderTemplate(template, vars) {
  const v = vars || {};
  switch (template) {
    case 'order_confirmed':
      return {
        subject: `Order #${v.orderId} Confirmed`,
        html: `<h2>Order Confirmed</h2><p>Your order <b>#${v.orderId}</b> is confirmed.</p><p>Items: ${v.items}</p><p>Total: ₹${v.total}</p>`
      };
    case 'order_shipped':
      return {
        subject: `Order #${v.orderId} Shipped`,
        html: `<h2>Order Shipped</h2><p>Your order <b>#${v.orderId}</b> is on the way.</p>`
      };
    case 'order_completed':
      return {
        subject: `Order #${v.orderId} Completed`,
        html: `<h2>Order Completed</h2><p>We hope you enjoy your purchase.</p>`
      };
    case 'subscription_activated':
      return {
        subject: `Subscription Activated`,
        html: `<h2>Subscription Activated</h2><p>Your plan is active. Benefits: ${(v.benefits||[]).join(', ')}</p>`
      };
    case 'technician_assigned':
      return {
        subject: `Assigned to Order #${v.orderId}`,
        html: `<h2>New Assignment</h2><p>You have been assigned to order <b>#${v.orderId}</b>.</p>`
      };
    default:
      return { subject: 'Notification', html: `<pre>${JSON.stringify(v, null, 2)}</pre>` };
  }
}

exports.sendEmail = functions.https.onRequest(async (req, res) => {
  try {
    if (req.method !== 'POST') {
      return res.status(405).json({ ok: false, error: 'Method not allowed' });
    }
    const { to, subject, template, vars } = req.body || {};
    if (!to) return res.status(400).json({ ok: false, error: 'Missing to' });

    let content = { subject, html: '' };
    if (template) {
      content = renderTemplate(template, vars);
    } else if (!subject || !req.body.html) {
      return res.status(400).json({ ok: false, error: 'Provide template or subject+html' });
    } else {
      content.html = req.body.html;
    }

    const msg = { to, from: FROM, subject: subject || content.subject, html: content.html };
    await sgMail.send(msg);
    return res.json({ ok: true });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ ok: false, error: e.message });
  }
});
