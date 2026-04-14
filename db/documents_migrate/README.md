# db/documents_migrate

This directory is **frozen**. Do not add new migrations here.

All document-related tables have been migrated to the `publication` database.
New migrations for document or timeline tables must go in `db/publications_migrate`.

The models that previously inherited from `DocumentRecord` now inherit directly
from `PublicationRecord`. The `DocumentRecord` class has been removed.

See `plans/backlog/publication-consolidation-plan.md` for the consolidation history
and `adr/news-is-timeline.md` for the news domain decision.