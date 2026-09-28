import 'package:limit_it_app/core/models/plan_model.dart';

/// Single source of truth for the store product IDs behind each backend plan.
///
/// A plan resolves to a product in two steps:
///
///  1. **`plan.productId` from the backend** — the correct way. Each plan
///     carries its own product ID, so several plans can share a billing cycle
///     (e.g. a cheap and an expensive monthly plan) as long as each one has its
///     own product in App Store Connect / Play Console.
///  2. **Billing-cycle fallback** — used only for plans the backend has not
///     given a `productId` yet, so older payloads keep working. It maps one
///     product per cycle, which means two plans in the same cycle would land on
///     the same product; [resolveProductId] blocks the purchase in that case
///     instead of charging the wrong amount.
const Map<String, String> _fallbackProductIdByCycle = {
  'weekly': 'limitit_weekly',
  'monthly': 'limitit_monthly',
  'yearly': 'limitit_yearly',
};

/// Billing cycle derived from the plan duration in days.
String billingCycleOf(PlanModel plan) {
  if (plan.duration >= 365) return 'yearly';
  if (plan.duration >= 28) return 'monthly';
  return 'weekly';
}

/// Store product ID for [plan], or `null` when no product covers it.
///
/// Use this for querying and price lookups. For starting a purchase use
/// [resolveProductId], which also rejects plans that collide.
String? productIdFor(PlanModel plan) =>
    plan.productId ?? _fallbackProductIdByCycle[billingCycleOf(plan)];

/// Every product ID to query from the store for [plans].
Set<String> productIdsFor(Iterable<PlanModel> plans) {
  final ids = <String>{};
  for (final plan in plans) {
    final id = productIdFor(plan);
    if (id != null) ids.add(id);
  }
  return ids;
}

/// Product ID to buy [plan] with, or `null` when it must not be purchased.
///
/// Returns `null` when the plan has no product at all, or when another plan in
/// [allPlans] resolves to the same product — a collision means we cannot tell
/// which price the store would charge, so the purchase is blocked rather than
/// guessed. Giving every plan its own `productId` on the backend is what keeps
/// collisions from happening.
String? resolveProductId(PlanModel plan, Iterable<PlanModel> allPlans) {
  final id = productIdFor(plan);
  if (id == null) return null;

  final collides = allPlans.any(
    (other) => other.id != plan.id && productIdFor(other) == id,
  );
  return collides ? null : id;
}
