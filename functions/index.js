const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

/**
 * Triggered on order creation.
 * Atomically deducts farmer, credits sellers, and reduces stock in a single transaction.
 */
exports.onOrderCreated = functions.firestore
  .document("orders/{orderId}")
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const orderId = context.params.orderId;
    const items = order.items || [];
    const farmerId = order.farmerId;
    const total = order.total || 0;
    const farmerBalanceAtCheckout = order.farmerBalanceAtCheckout || 0;

    await db.runTransaction(async (transaction) => {
      // 1. Read farmer doc to verify balance
      const farmerRef = db.collection("users").doc(farmerId);
      const farmerSnap = await transaction.get(farmerRef);

      if (!farmerSnap.exists) {
        throw new Error(`Farmer ${farmerId} not found`);
      }

      const farmerBalance = farmerSnap.data().balance || 0;

      if (farmerBalance < total) {
        throw new Error(
          `Insufficient balance: farmer has ${farmerBalance}, needs ${total}`
        );
      }

      // 2. Deduct from farmer
      transaction.update(farmerRef, {
        balance: admin.firestore.FieldValue.increment(-total),
      });

      // 3. Credit each seller & reduce product quantities
      const sellerTotals = {};
      for (const item of items) {
        const sellerId = item.sellerId;
        const amount = (item.price || 0) * (item.quantity || 0);
        sellerTotals[sellerId] = (sellerTotals[sellerId] || 0) + amount;

        const productRef = db.collection("products").doc(item.productId);
        transaction.update(productRef, {
          quantity: admin.firestore.FieldValue.increment(
            -(item.quantity || 0)
          ),
        });
      }

      for (const [sellerId, amount] of Object.entries(sellerTotals)) {
        const sellerRef = db.collection("users").doc(sellerId);
        transaction.update(sellerRef, {
          balance: admin.firestore.FieldValue.increment(amount),
        });
      }

      // 4. Mark order as confirmed
      transaction.update(snap.ref, { status: "confirmed" });
    });

    console.log(`Order ${orderId} processed atomically`);
  });
