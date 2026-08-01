/// Cross-cutting infrastructure for the White Label Commerce Platform.
///
/// This package has zero dependency on Flutter, on any feature package, or
/// on either app - it sits at the base of the dependency graph
/// (see docs/02_PROJECT_STRUCTURE.md §4 and §13).
///
/// Populated across Phase 2 ("Core Architecture") milestones per
/// docs/03_DEVELOPMENT_PHASES.md: error handling (`Result`/`Failure`),
/// `UseCase` base classes, DI bootstrap, logging, configuration
/// (`AppConfig`/`TenantConfig`/`FeatureFlags`), pagination envelope, and
/// shared utilities/entities.
///
/// Nothing is exported yet - this barrel file is a placeholder created in
/// Phase 1 (Project Foundation) so the package compiles as part of the
/// monorepo before its real contents are added.
library;
