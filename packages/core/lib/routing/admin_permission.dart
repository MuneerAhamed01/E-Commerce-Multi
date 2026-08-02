/// Permission tags used by admin route guards
/// (docs/09_ROUTING_PLAN.md §3.2 / §4 rule 3).
///
/// Concrete role → permission mapping arrives with Phase 21 (Admin
/// Foundation). Until then, [AuthSessionState.adminPermissions] is empty
/// for every session and permission-gated routes redirect to access-denied
/// once a session exists without the required tag — keeping the guard
/// seam stable for Phase 5 routers.
enum AdminPermission {
  /// Any authenticated admin may access (dashboard, settings, …).
  anyAdmin,

  catalogManager,
  orderManager,
  marketingManager,
  superAdmin,
}
