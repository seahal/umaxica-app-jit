class SeedUniversalReferenceData < ActiveRecord::Migration[8.2]
  def up
    # UserOccurrenceStatus
    seed_ids(:user_occurrence_statuses, %w[NONE ACTIVE INACTIVE BLOCKED])

    # StaffOccurrenceStatus
    seed_ids(:staff_occurrence_statuses, %w[NONE ACTIVE INACTIVE BLOCKED])

    # UserIdentityAuditLevel (additional levels beyond the ones already seeded)
    seed_ids(:user_identity_audit_levels, %w[DEBUG FATAL UNKNOWN])

    # Timeline Audit Events
    seed_ids(:com_timeline_audit_events, %w[NONE CREATED UPDATED DESTROYED])
    seed_ids(:org_timeline_audit_events, %w[NONE CREATED UPDATED DESTROYED])
    seed_ids(:app_timeline_audit_events, %w[NONE CREATED UPDATED DESTROYED])

    # Document Audit Events
    seed_ids(:com_document_audit_events, %w[NONE CREATED UPDATED DESTROYED])
    seed_ids(:org_document_audit_events, %w[NONE CREATED UPDATED DESTROYED])
    seed_ids(:app_document_audit_events, %w[NONE CREATED UPDATED DESTROYED])
  end

  def down
    # No-op to avoid removing shared reference data
  end

  private

    def seed_ids(table_name, ids)
      return unless table_exists?(table_name)

      has_timestamps = column_exists?(table_name, :created_at)

      ids.each do |id|
        if has_timestamps
          execute <<~SQL.squish
            INSERT INTO #{table_name} (id, created_at, updated_at)
            VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            ON CONFLICT (id) DO NOTHING
          SQL
        else
          execute <<~SQL.squish
            INSERT INTO #{table_name} (id)
            VALUES ('#{id}')
            ON CONFLICT (id) DO NOTHING
          SQL
        end
      end
    end
end
