# IAP Plans — Backend Setup (what the app now expects)

**Status:** app side is done. This file is the backend + store checklist.

---

## 1. The bug we just fixed

`/plans` returns two plans in the same billing cycle:

| Plan | duration | price | cycle |
|---|---|---|---|
| Basic Plan | 30 | 9.99 | monthly |
| Pro Plan | 30 | 19.99 | monthly |
| Premium Plan | 365 | 149.99 | yearly |

The app used to pick the store product **from the billing cycle alone**
(`monthly → limitit_monthly`), so Basic and Pro both landed on the same
product. One store product has exactly one price, so buying Pro would have
charged the Basic price. The app refused to purchase instead, and logged:

```
====> No purchasable product for plan "Basic Plan" (limitit_monthly)
```

Yearly worked only because `Premium Plan` was the only 365-day plan — no
collision. Weekly showed nothing because there is no weekly plan at all.

**Rule to remember: one backend plan = one store product.** As long as two
plans can share a product, one of them cannot be sold.

---

## 2. What the app does now

Each plan carries its own store product ID:

1. If `plan.productId` is present in the `/plans` payload → the app buys that
   product.
2. If it is missing → the app falls back to the old cycle mapping
   (`limitit_weekly` / `limitit_monthly` / `limitit_yearly`), and still blocks
   the purchase when two plans collide.

So the app keeps working with the current payload; it just cannot sell two
plans of the same cycle until `productId` is added.

The plan card price now shows the **store's own localised price**
(`$9.99`, `€9.99`, `₹899`…) when the product is loaded, and falls back to the
DB price only until the store answers.

---

## 3. Backend changes

### 3.1 Schema — add `productId` to the Plan model

```js
// models/plan.model.js
productId: {
  type: String,
  required: true,
  unique: true,   // two plans must never share a store product
  trim: true,
},
```

### 3.2 Return it from every endpoint that returns a plan

`GET /plans?isActive=true` must include it:

```json
{
  "_id": "69a92a2866f3941cccdb939a",
  "name": "Basic Plan",
  "type": "monthly",
  "duration": 30,
  "price": 9.99,
  "productId": "limitit_basic_monthly",
  "limits": { "maxApps": 3, "dailyLimit": 60 },
  "isActive": true
}
```

Also include it anywhere else a plan is embedded/populated (e.g. the current
subscription response), and accept it in the admin create/update plan APIs.

If you use a `select`/projection or a serializer for plans, add `productId`
there too — otherwise it silently never reaches the app.

### 3.3 Migration for existing plans

```js
// run once
await Plan.updateOne({ name: 'Basic Plan'   }, { $set: { productId: 'limitit_basic_monthly'   } });
await Plan.updateOne({ name: 'Pro Plan'     }, { $set: { productId: 'limitit_pro_monthly'     } });
await Plan.updateOne({ name: 'Premium Plan' }, { $set: { productId: 'limitit_premium_yearly'  } });
```

Suggested IDs (any naming is fine — they only have to match the store
**exactly**, character for character, lowercase):

| Plan | duration | productId |
|---|---|---|
| Basic Plan | 30 | `limitit_basic_monthly` |
| Pro Plan | 30 | `limitit_pro_monthly` |
| Premium Plan | 365 | `limitit_premium_yearly` |
| (optional) Weekly Plan | 7 | `limitit_basic_weekly` |

### 3.4 Rules

- **Unique** — never give two plans the same `productId`; the app blocks the
  purchase if you do.
- **Never change it after release** — an existing product ID cannot be renamed
  in App Store Connect / Play Console, and changing it breaks renewals for
  users who already subscribed. Create a new product + new plan instead.
- **Keep `price` in sync with the store price.** The card shows the store
  price, but `price` is still used for the "Save X%" yearly badge and for
  reporting, so a stale value shows a wrong discount.
- **Only one plan per cycle should stay active without `productId`.** Until the
  migration runs, deactivate either Basic or Pro (`isActive: false`) if you
  want monthly to be purchasable today.

---

## 4. Store side (App Store Connect + Google Play Console)

For **each** plan, create an auto-renewable subscription:

1. **App Store Connect** → App → Subscriptions → your subscription group
   (all LimitIt plans go in the **same group**, so users can upgrade/downgrade
   between them).
   - Product ID = exactly the `productId` you put in the DB.
   - Duration = 1 week / 1 month / 1 year, matching `duration`.
   - Price = the same amount as `price`.
   - Add a localisation + review screenshot, then set state to
     **Ready to Submit** — products in "Missing Metadata" are not returned by
     `queryProductDetails` and the plan will look unavailable in the app.
   - Paid Apps agreement must be active, or nothing loads at all.
2. **Google Play Console** → Monetize → Subscriptions → create the same
   product IDs, one base plan each, then **Activate** them.
   - The app must be uploaded to at least the internal testing track.
3. Add sandbox / licence testers (Users and Access → Sandbox Testers on iOS,
   Licence testing on Play) and test with those accounts — real money is not
   charged.

**Weekly:** there is no weekly plan today. If you want the weekly tab to show
something, create the plan in the DB *and* the matching store product; the tab
stays empty otherwise (that is intentional — better than showing a monthly
price under "Weekly").

### Verifying it worked

Run the app and check the logs:

```
====> Querying IAP products: {limitit_basic_monthly, limitit_pro_monthly, limitit_premium_yearly}
====> IAP products loaded: [limitit_basic_monthly, limitit_pro_monthly, limitit_premium_yearly]
```

If an ID appears under `IAP products missing from store:`, that product does
not exist / is not ready in the store for that platform — fix it there, the app
side is fine.

---

## 5. Recommended next (not required for the fix)

`POST /subscriptions/subscribe` currently trusts `{ planId, paymentId }` from
the client and activates the subscription. Anyone can call it with a made-up
`paymentId` and get premium for free. Before going live, verify the purchase
server-side:

- Have the app send the platform + purchase token/receipt as well.
- Validate against Apple (App Store Server API / `verifyReceipt`) or Google
  (Play Developer API `purchases.subscriptions.get`).
- Check that the verified product ID equals the plan's `productId`, and store
  the store transaction ID so the same purchase cannot be redeemed twice.
- Handle renewal/cancellation via App Store Server Notifications V2 and Play
  Real-time Developer Notifications, so expiry stays correct without the app.

---

## Checklist

- [ ] `productId` added to Plan schema (unique, required)
- [ ] `productId` returned by `GET /plans` and every other plan payload
- [ ] Admin create/update plan accepts `productId`
- [ ] Migration run for Basic / Pro / Premium
- [ ] `price` matches the store price for every plan
- [ ] Products created + Ready to Submit / Activated in both stores
- [ ] Sandbox purchase tested for monthly **and** yearly
- [ ] (later) server-side receipt verification on `/subscriptions/subscribe`
