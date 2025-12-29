# frozen_string_literal: true

class SeedGuestReferenceData < ActiveRecord::Migration[8.2]
  def up
    # ComContactCategory
    seed_with_attributes(
      :com_contact_categories, [
        { id: 'SECURITY_ISSUE', description: 'root of corporate site status inquiries', parent_id: 'NULL' },
        { id: 'OTHERS', description: 'root of corporate site status inquiries', parent_id: 'NULL' },
      ],
    )

    # AppContactCategory
    seed_with_attributes(
      :app_contact_categories, [
        { id: 'NULL', description: 'NULL' },
        { id: 'NULL_CONTACT_STATUS', description: 'NULL' },
        { id: 'COULD_NOT_SIGN_IN', description: 'user had a problem to sign/log in' },
        { id: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries' },
      ],
    )

    # OrgContactCategory
    seed_with_attributes(
      :org_contact_categories, [
        { id: 'COULD_NOT_SIGN_IN', description: 'user had a problem to sign/log in' },
        { id: 'NULL_CONTACT_STATUS', description: 'NULL' },
        { id: 'APEX_OF_ORG', description: 'root of org site status inquiries' },
        { id: 'ORGANIZATION_SITE_CONTACT', description: 'root of org site status inquiries' },
      ],
    )

    # ComContactStatus
    seed_with_attributes(
      :com_contact_statuses, [
        { id: 'NEYO', description: 'NEYO' },
        { id: 'SET_UP', description: 'first step completed' },
        { id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_id: 'SET_UP' },
        { id: 'CHECKED_TELEPHONE_NUMBER', description: 'second step completed', parent_id: 'CHECKED_EMAIL_ADDRESS' },
        { id: 'COMPLETED_CONTACT_ACTION', description: 'second step completed', parent_id: 'CHECKED_TELEPHONE_NUMBER' },
      ],
    )

    # AppContactStatus
    seed_with_attributes(
      :app_contact_statuses, [
        { id: 'NEYO', description: 'NEYO' },
        { id: 'STAFF_SITE_STATUS', description: 'root of staff site status inquiries' },
      ],
    )

    # OrgContactStatus
    seed_with_attributes(
      :org_contact_statuses, [
        { id: 'NEYO', description: 'NEYO' },
        { id: 'ORG_SITE_STATUS', description: 'root of org site status inquiries' },
        { id: 'SET_UP', description: 'first step completed' },
        { id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_id: 'SET_UP' },
        { id: 'CHECKED_TELEPHONE_NUMBER', description: 'third step completed', parent_id: 'CHECKED_EMAIL_ADDRESS' },
        { id: 'COMPLETED_CONTACT_ACTION', description: 'contact action completed', parent_id: 'CHECKED_TELEPHONE_NUMBER' },
      ],
    )

    # Contact Audit Events
    seed_ids(:com_contact_audit_events, %w(NEYO CREATED UPDATED DESTROYED))
    seed_ids(:app_contact_audit_events, %w(NEYO CREATED UPDATED DESTROYED))
    seed_ids(:org_contact_audit_events, %w(NEYO CREATED UPDATED DESTROYED))
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

  def seed_with_attributes(table_name, records)
    return unless table_exists?(table_name)

    has_timestamps = column_exists?(table_name, :created_at)

    records.each do |record|
      columns = record.keys
      values =
        record.values.map do |v|
          v.nil? ? 'NULL' : "'#{v.to_s.gsub("'", "''")}'"
        end

      if has_timestamps
        columns += [:created_at, :updated_at]
        values += ['CURRENT_TIMESTAMP', 'CURRENT_TIMESTAMP']
      end

      execute <<~SQL.squish
        INSERT INTO #{table_name} (#{columns.join(", ")})
        VALUES (#{values.join(", ")})
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end
end
