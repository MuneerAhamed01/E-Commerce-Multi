# Shared mock seed fixtures

Canonical cross-feature seed data for Phase 6 (`docs/03_DEVELOPMENT_PHASES.md`
milestone 6.2).

Feature mock data sources should **import from here** until a feature owns
enough of a dataset to justify moving it into
`packages/features/<feature>/lib/src/data/mock/`. Do not duplicate seed lists
per feature while this package remains the source of truth.

Volume targets (pagination demos): dozens of products, multiple categories,
customers, and sample orders.
