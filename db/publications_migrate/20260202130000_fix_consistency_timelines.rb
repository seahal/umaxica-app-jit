# frozen_string_literal: true

class FixConsistencyTimelines < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # Truncate
      tables = %w(
        org_timelines org_timeline_revisions org_timeline_versions org_timeline_tags org_timeline_categories
        com_timelines com_timeline_revisions com_timeline_versions com_timeline_tags com_timeline_categories
        app_timelines app_timeline_revisions app_timeline_versions app_timeline_tags app_timeline_categories
      )
      existing = tables.select { |t| table_exists?(t) }
      execute("TRUNCATE TABLE #{existing.join(", ")} CASCADE") if existing.any?

      # --- OrgTimeline ---
      if foreign_key_exists?(:org_timeline_revisions, :org_timelines)
        remove_foreign_key(:org_timeline_revisions, :org_timelines)
      end
      add_foreign_key(:org_timeline_revisions, :org_timelines, on_delete: :cascade)

      add_index(:org_timeline_tags, :org_timeline_id) unless index_exists?(:org_timeline_tags, :org_timeline_id)

      # --- ComTimeline ---
      if foreign_key_exists?(:com_timeline_revisions, :com_timelines)
        remove_foreign_key(:com_timeline_revisions, :com_timelines)
      end
      add_foreign_key(:com_timeline_revisions, :com_timelines, on_delete: :cascade)

      add_index(:com_timeline_tags, :com_timeline_id) unless index_exists?(:com_timeline_tags, :com_timeline_id)

      # --- AppTimeline ---
      if foreign_key_exists?(:app_timeline_revisions, :app_timelines)
        remove_foreign_key(:app_timeline_revisions, :app_timelines)
      end
      add_foreign_key(:app_timeline_revisions, :app_timelines, on_delete: :cascade)

      add_index(:app_timeline_tags, :app_timeline_id) unless index_exists?(:app_timeline_tags, :app_timeline_id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
