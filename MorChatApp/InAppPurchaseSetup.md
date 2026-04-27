# In-App Purchase Setup

This project now expects the following consumable product identifiers in App Store Connect:

- `com.morchat.coins.100`
- `com.morchat.coins.500`
- `com.morchat.coins.1000`

## What is already implemented in the app

- StoreKit 2 product loading
- Native purchase flow
- `AppStore.sync()` restore trigger
- Unfinished transaction handling on launch
- Idempotent coin crediting in Firestore using transaction records
- Wallet UI updates after successful purchase or rewarded ad credit

## App Store Connect checklist

1. Create the three consumable in-app purchases with the exact product IDs above.
2. Add localized display name, description, and pricing for each product.
3. Complete Paid Applications agreement, tax, and banking setup.
4. Attach the in-app purchases to the app version you plan to submit.
5. Test purchases with Sandbox or TestFlight accounts before release.

## Firebase / Firestore note

Successful purchases create a record under:

- `UserWatcher/{uid}/coinPurchases/{transactionId}`

This prevents duplicate coin grants if Apple re-delivers an unfinished transaction.
