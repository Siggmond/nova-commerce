import * as admin from 'firebase-admin';
import { HttpsError, onCall, onRequest, type CallableRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import Stripe from 'stripe';

admin.initializeApp();

const stripeSecret = defineSecret('STRIPE_SECRET_KEY');
const stripeWebhookSecret = defineSecret('STRIPE_WEBHOOK_SECRET');

let _stripe: Stripe | null = null;

function demoPaymentsAllowed(): boolean {
  const allow = (process.env.ALLOW_DEMO_PAYMENTS ?? '').trim().toLowerCase() === 'true';
  const emulator =
    (process.env.FUNCTIONS_EMULATOR ?? '').trim().toLowerCase() === 'true' ||
    !!process.env.FIREBASE_EMULATOR_HUB;
  return allow || emulator;
}

function stripeClient(): Stripe {
  if (_stripe) return _stripe;
  const key = stripeSecret.value() ?? '';
  if (!key.trim()) {
    throw new HttpsError(
      'failed-precondition',
      'Stripe is not configured. Set STRIPE_SECRET_KEY in Functions secrets.',
    );
  }

  _stripe = new Stripe(key.trim(), {
    apiVersion: '2023-10-16',
  });
  return _stripe;
}

type CartLine = {
  productId: string;
  quantity: number;
  selectedColor: string;
  selectedSize: string;
};

type PriceBreakdown = {
  currency: string;
  subtotalMinor: number;
  discountMinor: number;
  shippingMinor: number;
  taxMinor: number;
  totalMinor: number;
};

type Shipping = {
  fullName: string;
  phone: string;
  address: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
};

function requireAuth(context: { auth?: { uid: string } | null }) {
  const uid = context.auth?.uid ?? '';
  if (!uid.trim()) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  return uid.trim();
}

function normalizeCurrency(raw: unknown): string {
  const c = (typeof raw === 'string' ? raw : 'USD').trim();
  return c ? c.toLowerCase() : 'usd';
}

function asString(v: unknown): string {
  return typeof v === 'string' ? v : '';
}

function asInt(v: unknown): number {
  if (typeof v === 'number' && Number.isFinite(v)) return Math.trunc(v);
  if (typeof v === 'string') {
    const n = parseInt(v, 10);
    return Number.isFinite(n) ? n : 0;
  }
  return 0;
}

function sanitizeShipping(raw: unknown): Shipping {
  const m = raw && typeof raw === 'object' ? (raw as any) : {};
  return {
    fullName: asString(m.fullName).trim(),
    phone: asString(m.phone).trim(),
    address: asString(m.address).trim(),
    city: asString(m.city).trim(),
    state: asString(m.state).trim(),
    postalCode: asString(m.postalCode).trim(),
    country: asString(m.country).trim(),
  };
}

async function loadServerCart(uid: string): Promise<CartLine[]> {
  const snap = await admin.firestore().collection('carts').doc(uid).get();
  const data = snap.data() ?? {};
  const raw = (data as any).items;
  if (!Array.isArray(raw)) return [];

  const lines: CartLine[] = [];
  for (const e of raw) {
    if (!e || typeof e !== 'object') continue;
    const m = e as any;
    const productId = asString(m.productId).trim();
    const qty = asInt(m.quantity);
    const selectedColor = asString(m.selectedColor).trim();
    const selectedSize = asString(m.selectedSize).trim();
    if (!productId || qty <= 0 || !selectedColor || !selectedSize) continue;
    lines.push({ productId, quantity: qty, selectedColor, selectedSize });
  }
  return lines;
}

async function computeTotalsFromProducts(lines: CartLine[]): Promise<{
  breakdown: PriceBreakdown;
  productSnaps: Record<string, admin.firestore.DocumentSnapshot>;
}> {
  if (lines.length === 0) {
    return {
      breakdown: {
        currency: 'usd',
        subtotalMinor: 0,
        discountMinor: 0,
        shippingMinor: 0,
        taxMinor: 0,
        totalMinor: 0,
      },
      productSnaps: {},
    };
  }

  const byProductId: Record<string, CartLine[]> = {};
  for (const l of lines) {
    byProductId[l.productId] ??= [];
    byProductId[l.productId].push(l);
  }

  const productSnaps: Record<string, admin.firestore.DocumentSnapshot> = {};
  let currency: string | null = null;
  let subtotalMinor = 0;

  // Firestore reads (no transaction needed here; finalizeOrder uses transaction).
  for (const productId of Object.keys(byProductId)) {
    const snap = await admin.firestore().collection('products').doc(productId).get();
    if (!snap.exists) {
      throw new HttpsError('failed-precondition', 'A product is no longer available.');
    }
    productSnaps[productId] = snap;

    const data = snap.data() ?? {};
    const productCurrency = normalizeCurrency((data as any).currency);
    currency ??= productCurrency;
    if (currency !== productCurrency) {
      throw new HttpsError('failed-precondition', 'Cart contains multiple currencies.');
    }

    const priceMajor = typeof (data as any).price === 'number' ? (data as any).price : 0;
    const unitMinor = Math.round(priceMajor * 100);

    for (const line of byProductId[productId]) {
      subtotalMinor += unitMinor * line.quantity;
    }
  }

  const discountMinor = 0;
  const shippingMinor = 1000;
  const taxMinor = 200;
  const totalMinor = subtotalMinor - discountMinor + shippingMinor + taxMinor;

  return {
    breakdown: {
      currency: currency ?? 'usd',
      subtotalMinor,
      discountMinor,
      shippingMinor,
      taxMinor,
      totalMinor,
    },
    productSnaps,
  };
}

async function ensureStripeReady() {
  // Accessing the secret value validates it and ensures the secret is mounted.
  stripeClient();
}

async function ensureStripeWebhookReady() {
  const secret = stripeWebhookSecret.value() ?? '';
  if (!secret.trim()) {
    throw new HttpsError(
      'failed-precondition',
      'Stripe webhook is not configured. Set STRIPE_WEBHOOK_SECRET in Functions secrets.',
    );
  }
  return secret.trim();
}

async function findExistingOrderIdByPaymentIntent(
  paymentIntentId: string,
): Promise<string | null> {
  const snap = await admin
    .firestore()
    .collection('orders')
    .where('paymentIntentId', '==', paymentIntentId)
    .limit(1)
    .get();

  if (snap.empty) return null;
  return snap.docs[0].id;
}

async function loadPaymentSession(paymentIntentId: string) {
  const doc = await admin
    .firestore()
    .collection('payment_sessions')
    .doc(paymentIntentId)
    .get();
  const data = doc.data() ?? null;
  return { exists: doc.exists, data };
}

async function finalizeOrderCore({
  uid,
  paymentIntentId,
  deviceId,
  shipping,
  cartLines,
  paymentProvider,
}: {
  uid: string;
  paymentIntentId: string;
  deviceId: string;
  shipping: Shipping;
  cartLines?: CartLine[];
  paymentProvider?: string;
}): Promise<string> {
  const existing = await findExistingOrderIdByPaymentIntent(paymentIntentId);
  if (existing) return existing;

  const lines = cartLines && cartLines.length > 0 ? cartLines : await loadServerCart(uid);
  if (lines.length === 0) {
    throw new HttpsError('failed-precondition', 'Your cart is empty.');
  }

  const { breakdown } = await computeTotalsFromProducts(lines);

  const db = admin.firestore();

  const orderId = await db.runTransaction(async (tx: admin.firestore.Transaction) => {
    const lockRef = db.collection('payment_intent_locks').doc(paymentIntentId);
    const lockSnap = await tx.get(lockRef);
    if (lockSnap.exists) {
      const d = lockSnap.data() as any;
      const lockedOrderId = asString(d?.orderId).trim();
      if (lockedOrderId) return lockedOrderId;
    }

    const existingInTx = await tx.get(
      db
        .collection('orders')
        .where('paymentIntentId', '==', paymentIntentId)
        .limit(1),
    );
    if (!existingInTx.empty) {
      const found = existingInTx.docs[0].id;
      tx.set(
        lockRef,
        {
          uid,
          orderId: found,
          paymentIntentId,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return found;
    }

    const byProductId: Record<string, CartLine[]> = {};
    for (const l of lines) {
      byProductId[l.productId] ??= [];
      byProductId[l.productId].push(l);
    }

    const productRefs: Record<string, admin.firestore.DocumentReference> = {};
    const productSnaps: Record<string, admin.firestore.DocumentSnapshot> = {};

    // READS FIRST.
    for (const productId of Object.keys(byProductId)) {
      const ref = db.collection('products').doc(productId);
      productRefs[productId] = ref;
      const snap = await tx.get(ref);
      if (!snap.exists) {
        throw new HttpsError('failed-precondition', 'A product is no longer available.');
      }
      productSnaps[productId] = snap;
    }

    // Compute variant updates.
    for (const productId of Object.keys(byProductId)) {
      const snap = productSnaps[productId];
      const data = (snap.data() ?? {}) as any;
      const title = asString(data.title) || 'Product';

      const variantsRaw = data.variants;
      if (!Array.isArray(variantsRaw)) {
        throw new HttpsError(
          'failed-precondition',
          `${title} is not available in the selected variant.`,
        );
      }

      const updated = variantsRaw
        .filter((v: any) => v && typeof v === 'object')
        .map((v: any) => ({ ...v }));

      for (const line of byProductId[productId]) {
        const idx = updated.findIndex((v: any) => {
          const c = asString(v.color).trim();
          const s = asString(v.size).trim();
          return c === line.selectedColor && s === line.selectedSize;
        });

        if (idx < 0) {
          throw new HttpsError(
            'failed-precondition',
            `${title} (${line.selectedColor} • ${line.selectedSize}) is no longer available.`,
          );
        }

        const currentStock = asInt(updated[idx].stock);
        if (currentStock < line.quantity) {
          throw new HttpsError(
            'failed-precondition',
            `${title} (${line.selectedColor} • ${line.selectedSize}) has only ${currentStock} left.`,
          );
        }

        updated[idx].stock = currentStock - line.quantity;
      }

      tx.update(productRefs[productId], {
        variants: updated,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    const orderRef = db.collection('orders').doc();

    const items: any[] = [];
    for (const line of lines) {
      const snap = productSnaps[line.productId];
      const data = (snap.data() ?? {}) as any;
      items.push({
        productId: line.productId,
        title: asString(data.title) || 'Product',
        price: typeof data.price === 'number' ? data.price : 0,
        quantity: line.quantity,
        selectedColor: line.selectedColor,
        selectedSize: line.selectedSize,
      });
    }

    tx.set(orderRef, {
      uid,
      deviceId,
      status: 'paid',
      currency: breakdown.currency.toUpperCase(),
      subtotal: breakdown.subtotalMinor / 100,
      shippingFee: breakdown.shippingMinor / 100,
      total: breakdown.totalMinor / 100,
      amountMinor: breakdown.totalMinor,
      paymentStatus: 'paid',
      paymentProvider: (paymentProvider ?? 'stripe').trim() || 'stripe',
      paymentIntentId,
      shipping: {
        fullName: shipping.fullName,
        phone: shipping.phone,
        address: shipping.address,
        city: shipping.city,
        country: shipping.country,
        state: shipping.state,
        postalCode: shipping.postalCode,
      },
      items,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const cartRef = db.collection('carts').doc(uid);
    tx.set(
      cartRef,
      {
        uid,
        items: [],
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    tx.set(
      lockRef,
      {
        uid,
        orderId: orderRef.id,
        paymentIntentId,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    return orderRef.id;
  });

  return orderId;
}

export const stripeWebhook = onRequest({ secrets: [stripeSecret, stripeWebhookSecret] }, async (req, res) => {
  try {
    const secret = await ensureStripeWebhookReady();

    if (req.method !== 'POST') {
      res.status(405).send('Method not allowed');
      return;
    }

    const sig = (req.headers['stripe-signature'] as string | undefined) ?? '';
    if (!sig.trim()) {
      res.status(400).send('Missing stripe-signature header');
      return;
    }

    const rawBody = (req as any).rawBody as Buffer | undefined;
    if (!rawBody) {
      res.status(400).send('Missing rawBody');
      return;
    }

    const event = stripeClient().webhooks.constructEvent(rawBody, sig, secret);

    if (event.type !== 'payment_intent.succeeded') {
      res.status(200).json({ received: true });
      return;
    }

    const intent = event.data.object as Stripe.PaymentIntent;
    const paymentIntentId = intent.id;
    const uid = asString((intent.metadata as any)?.uid).trim();
    if (!uid) {
      // Can't finalize without knowing owner.
      res.status(200).json({ received: true });
      return;
    }

    const existing = await findExistingOrderIdByPaymentIntent(paymentIntentId);
    if (existing) {
      res.status(200).json({ received: true, orderId: existing });
      return;
    }

    const session = await loadPaymentSession(paymentIntentId);
    if (!session.exists || !session.data) {
      // Ask Stripe to retry: session may arrive shortly after intent creation.
      res.status(500).send('Missing payment session context');
      return;
    }

    const sessionUid = asString((session.data as any).uid).trim();
    if (sessionUid && sessionUid !== uid) {
      res.status(200).json({ received: true });
      return;
    }

    const deviceId = asString((session.data as any).deviceId).trim();
    const shipping = sanitizeShipping((session.data as any).shipping);
    const cartLinesRaw = (session.data as any).cartLines;
    const cartLines = Array.isArray(cartLinesRaw)
      ? cartLinesRaw
          .filter((e: any) => e && typeof e === 'object')
          .map((e: any) => ({
            productId: asString(e.productId).trim(),
            quantity: asInt(e.quantity),
            selectedColor: asString(e.selectedColor).trim(),
            selectedSize: asString(e.selectedSize).trim(),
          }))
          .filter(
            (l: any) =>
              l.productId &&
              l.quantity > 0 &&
              l.selectedColor &&
              l.selectedSize,
          )
      : undefined;

    const orderId = await finalizeOrderCore({
      uid,
      paymentIntentId,
      deviceId,
      shipping,
      cartLines,
    });

    res.status(200).json({ received: true, orderId });
  } catch (e: any) {
    // Signature errors should not be retried.
    const msg = asString(e?.message);
    if (msg.toLowerCase().includes('signature')) {
      res.status(400).send('Invalid signature');
      return;
    }

    res.status(500).send('Webhook error');
  }
});

export const createPaymentIntent = onCall({ secrets: [stripeSecret] }, async (request: CallableRequest) => {
  const uid = requireAuth(request);
  await ensureStripeReady();

  const payload = (request.data ?? {}) as any;
  const shipping = sanitizeShipping(payload.shipping);
  const deviceId = asString(payload.deviceId).trim();

  const lines = await loadServerCart(uid);
  if (lines.length === 0) {
    throw new HttpsError('failed-precondition', 'Your cart is empty.');
  }

  const { breakdown } = await computeTotalsFromProducts(lines);

  const intent = await stripeClient().paymentIntents.create({
    amount: breakdown.totalMinor,
    currency: breakdown.currency,
    automatic_payment_methods: { enabled: true },
    metadata: {
      uid,
    },
  });

  // Persist session context so webhook can finalize if the app closes.
  await admin
    .firestore()
    .collection('payment_sessions')
    .doc(intent.id)
    .set(
      {
        uid,
        deviceId,
        shipping,
        cartLines: lines,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  if (!intent.client_secret) {
    throw new HttpsError('internal', 'Stripe did not return a client secret.');
  }

  return {
    clientSecret: intent.client_secret,
    paymentIntentId: intent.id,
    amountMinor: breakdown.totalMinor,
    currency: breakdown.currency,
    breakdown,
  };
});

export const finalizeOrderFromPaymentIntent = onCall({ secrets: [stripeSecret] }, async (request: CallableRequest) => {
  const uid = requireAuth(request);
  await ensureStripeReady();

  const data = (request.data ?? {}) as any;
  const paymentIntentId = asString(data.paymentIntentId).trim();
  const deviceId = asString(data.deviceId).trim();
  const shipping = sanitizeShipping(data.shipping);

  if (!paymentIntentId) {
    throw new HttpsError('invalid-argument', 'Missing paymentIntentId');
  }

  const existing = await findExistingOrderIdByPaymentIntent(paymentIntentId);
  if (existing) {
    return { orderId: existing };
  }

  const intent = await stripeClient().paymentIntents.retrieve(paymentIntentId);
  const intentUid = asString((intent.metadata as any)?.uid).trim();
  if (!intentUid || intentUid !== uid) {
    throw new HttpsError('permission-denied', 'Payment does not belong to user.');
  }

  if (intent.status !== 'succeeded') {
    throw new HttpsError(
      'failed-precondition',
      `Payment is not complete (status=${intent.status}).`,
    );
  }

  const session = await loadPaymentSession(paymentIntentId);
  const cartLinesRaw = session.data ? (session.data as any).cartLines : null;
  const cartLines = Array.isArray(cartLinesRaw)
    ? cartLinesRaw
        .filter((e: any) => e && typeof e === 'object')
        .map((e: any) => ({
          productId: asString(e.productId).trim(),
          quantity: asInt(e.quantity),
          selectedColor: asString(e.selectedColor).trim(),
          selectedSize: asString(e.selectedSize).trim(),
        }))
        .filter(
          (l: any) => l.productId && l.quantity > 0 && l.selectedColor && l.selectedSize,
        )
    : undefined;

  const orderId = await finalizeOrderCore({
    uid,
    paymentIntentId,
    deviceId,
    shipping,
    cartLines,
    paymentProvider: 'stripe',
  });

  return { orderId };
});

export const createDemoPaymentSession = onCall(async (request: CallableRequest) => {
  const uid = requireAuth(request);
  if (!demoPaymentsAllowed()) {
    throw new HttpsError('permission-denied', 'Demo payments are disabled.');
  }

  const payload = (request.data ?? {}) as any;
  const shipping = sanitizeShipping(payload.shipping);
  const deviceId = asString(payload.deviceId).trim();

  const lines = await loadServerCart(uid);
  if (lines.length === 0) {
    throw new HttpsError('failed-precondition', 'Your cart is empty.');
  }

  const { breakdown } = await computeTotalsFromProducts(lines);
  const db = admin.firestore();
  const demoPaymentIntentId = `demo_${db.collection('payment_sessions').doc().id}`;

  await db
    .collection('payment_sessions')
    .doc(demoPaymentIntentId)
    .set(
      {
        uid,
        deviceId,
        shipping,
        cartLines: lines,
        mode: 'demo',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  return {
    clientSecret: 'demo',
    paymentIntentId: demoPaymentIntentId,
    amountMinor: breakdown.totalMinor,
    currency: breakdown.currency,
    breakdown,
  };
});

export const finalizeDemoOrderFromPaymentSession = onCall(async (request: CallableRequest) => {
  const uid = requireAuth(request);
  if (!demoPaymentsAllowed()) {
    throw new HttpsError('permission-denied', 'Demo payments are disabled.');
  }

  const data = (request.data ?? {}) as any;
  const paymentIntentId = asString(data.paymentIntentId).trim();
  const deviceId = asString(data.deviceId).trim();
  const shipping = sanitizeShipping(data.shipping);

  if (!paymentIntentId) {
    throw new HttpsError('invalid-argument', 'Missing paymentIntentId');
  }

  const existing = await findExistingOrderIdByPaymentIntent(paymentIntentId);
  if (existing) {
    return { orderId: existing };
  }

  const session = await loadPaymentSession(paymentIntentId);
  const sessionUid = session.data ? asString((session.data as any).uid).trim() : '';
  if (!session.exists || !session.data || !sessionUid || sessionUid !== uid) {
    throw new HttpsError('failed-precondition', 'Missing demo payment session.');
  }

  const cartLinesRaw = (session.data as any).cartLines;
  const cartLines = Array.isArray(cartLinesRaw)
    ? cartLinesRaw
        .filter((e: any) => e && typeof e === 'object')
        .map((e: any) => ({
          productId: asString(e.productId).trim(),
          quantity: asInt(e.quantity),
          selectedColor: asString(e.selectedColor).trim(),
          selectedSize: asString(e.selectedSize).trim(),
        }))
        .filter(
          (l: any) => l.productId && l.quantity > 0 && l.selectedColor && l.selectedSize,
        )
    : undefined;

  const orderId = await finalizeOrderCore({
    uid,
    paymentIntentId,
    deviceId,
    shipping,
    cartLines,
    paymentProvider: 'demo',
  });

  return { orderId };
});
