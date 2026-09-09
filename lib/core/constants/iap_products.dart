import 'package:limit_it_app/core/models/plan_model.dart';

/// Single source of truth for the store product IDs behind each backend plan.
///
/// The store side has exactly one product per billing cycle, matching the
/// subscription group in App Store Connect / Google Play Console:
///   - Weekly Plan  → `limitit_weekly`   (1 week)
///   - Monthly Plan → `limitit_monthly`  (1 month)
///   - Yearly Plan  → `limitit_yearly`   (1 year)
///
/// So a backend plan resolves to a product purely by its billing cycle. That
/// only works while `/plans` returns **one plan per cycle** — two monthly plans
/// would both land on `limitit_monthly` and the cheaper one's price would be
/// charged for both. [resolveProductId] refuses to purchase in that case
/// instead of charging the wrong amount.
const Map<String, String> _productIdByCycle = {
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

/// Store product ID for [plan], or `null` when no product covers its cycle.
///
/// Use this for querying and price lookups. For starting a purchase use
/// [resolveProductId], which also rejects plans that collide.
String? productIdFor(PlanModel plan) => _productIdByCycle[billingCycleOf(plan)];

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
/// Returns `null` when the plan has no product for its cycle, or when another
/// plan in [allPlans] maps to the same product — a collision means we cannot
/// tell which price the store would charge, so the purchase is blocked rather
/// than guessed.
String? resolveProductId(PlanModel plan, Iterable<PlanModel> allPlans) {
  final id = productIdFor(plan);
  if (id == null) return null;

  final collides = allPlans.any(
    (other) => other.id != plan.id && productIdFor(other) == id,
  );
  return collides ? null : id;
}
