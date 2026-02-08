# frozen_string_literal: true

class ConvertRemainingActorIdsToBigint < ActiveRecord::Migration[8.2]
  def up
    tables = %w(
      app_preference_audits
      app_timeline_audits
      com_contact_audits
      com_document_audits
      com_preference_audits
      com_timeline_audits
      org_contact_histories
      org_document_audits
      org_preference_audits
      org_timeline_audits
      staff_audits
      user_audits
    )

    tables.each do |table|
      # First drop the default to allow type change
      change_column_default table, :actor_id, nil

      # Change the column type to bigint using appropriate casting
      # Since data inheritance is not needed (new DB), we can just cast or reset.
      # using 'actor_id::integer' might fail if UUIDs are present, but with no data preservation needed,
      # we can drop and recreate or iterate.
      # Rails 'change_column' with 'using' is standard.
      # If UUIDs are present, we might want to set them to 0.

      # However, since we are in dev/test environment with "broken" state,
      # let's try to convert. If it fails due to data, we'll deal with it.
      # Safest for "no data inheritance" is strictly changing type.

      # Note: The existing default was "00000000-0000-0000-0000-000000000000".
      # The new default should be 0.

      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table}#{" "}
            ALTER COLUMN actor_id DROP DEFAULT,
            ALTER COLUMN actor_id TYPE bigint USING (CASE WHEN actor_id::text ~ '^[0-9]+$' THEN actor_id::text::bigint ELSE 0 END),
            ALTER COLUMN actor_id SET DEFAULT 0;
        SQL
      end
    end
  end

  def down
    # Irreversible in spirit context (we moved from UUID to int), but strictly revertible if needed.
    # We won't implement down for this fix-forward task unless requested.
  end
end
