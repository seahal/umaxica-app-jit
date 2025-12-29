# frozen_string_literal: true

class SeedUniversalConstants < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Occurrence Statuses
      standard_occurrence_statuses = [
        { id: 'NEYO' },
        { id: 'ACTIVE' },
        { id: 'INACTIVE' },
        { id: 'BLOCKED' },
      ]

      %w(
        area_occurrence_statuses domain_occurrence_statuses email_occurrence_statuses
        ip_occurrence_statuses telephone_occurrence_statuses zip_occurrence_statuses
        staff_occurrence_statuses user_occurrence_statuses
      ).each do |table|
        upsert_table(table, standard_occurrence_statuses)
      end

      # Extra ACTIVE with expiration for IP and Telephone
      # We upsert again with expires_at to overwrite
      extra_active = [{ id: 'ACTIVE', expires_at: '2099-01-01' }]
      upsert_table('ip_occurrence_statuses', extra_active)
      upsert_table('telephone_occurrence_statuses', extra_active)

      # Audit Levels
      # Group 1: NEYO, INFO, WARN, ERROR (App/Com/Org Document/Timeline)
      standard_levels = [
        { id: 'NEYO' },
        { id: 'INFO' },
        { id: 'WARN' },
        { id: 'ERROR' },
      ]
      %w(
        app_document_audit_levels app_timeline_audit_levels
        com_document_audit_levels com_timeline_audit_levels
        org_document_audit_levels org_timeline_audit_levels
      ).each do |table|
        upsert_table(table, standard_levels)
      end

      # Group 2: NEYO, INFO, WARN, ERROR (Staff/User Identity)
      identity_levels = [
        { id: 'NEYO' },
        { id: 'INFO' },
        { id: 'WARN' },
        { id: 'ERROR' },
      ]
      %w(staff_identity_audit_levels user_identity_audit_levels).each do |table|
        upsert_table(table, identity_levels)
      end

      # Audit Events
      # Group 1: CREATED, UPDATED, DELETED (App/Com/Org Document/Timeline)
      standard_events = [
        { id: 'CREATED' },
        { id: 'UPDATED' },
        { id: 'DELETED' },
      ]
      %w(
        app_document_audit_events app_timeline_audit_events
        com_document_audit_events com_timeline_audit_events
        org_document_audit_events org_timeline_audit_events
      ).each do |table|
        upsert_table(table, standard_events)
      end

      # StaffIdentityAuditEvent
      upsert_table(
        'staff_identity_audit_events', [
          { id: "LOGIN_SUCCESS" },
          { id: "LOGIN_FAILURE" },
          { id: "LOGGED_IN" },
          { id: "LOGGED_OUT" },
          { id: "LOGIN_FAILED" },
          { id: "AUTHORIZATION_FAILED" },
        ],
      )

      # UserIdentityAuditEvent
      upsert_table(
        'user_identity_audit_events', [
          { id: "LOGIN_SUCCESS" },
          { id: "LOGIN_FAILURE" },
          { id: "LOGGED_IN" },
          { id: "LOGGED_OUT" },
          { id: "LOGIN_FAILED" },
          { id: "TOKEN_REFRESHED" },
          { id: "SIGNED_UP_WITH_EMAIL" },
          { id: "SIGNED_UP_WITH_TELEPHONE" },
          { id: "SIGNED_UP_WITH_APPLE" },
          { id: "AUTHORIZATION_FAILED" },
        ],
      )
    end
  end

  def down
    safety_assured do
      %w(
        area_occurrence_statuses domain_occurrence_statuses email_occurrence_statuses
        ip_occurrence_statuses telephone_occurrence_statuses zip_occurrence_statuses
        staff_occurrence_statuses user_occurrence_statuses
        app_document_audit_levels app_timeline_audit_levels
        com_document_audit_levels com_timeline_audit_levels
        org_document_audit_levels org_timeline_audit_levels
        staff_identity_audit_levels user_identity_audit_levels
        app_document_audit_events app_timeline_audit_events
        com_document_audit_events com_timeline_audit_events
        org_document_audit_events org_timeline_audit_events
        staff_identity_audit_events user_identity_audit_events
      ).each do |table|
        execute "DELETE FROM #{table}"
      end
    end
  end

  private

  def upsert_table(table_name, rows)
    now = Time.current
    has_created_at = connection.column_exists?(table_name, :created_at)
    has_updated_at = connection.column_exists?(table_name, :updated_at)

    rows.each do |row|
      row[:created_at] ||= now if has_created_at
      row[:updated_at] ||= now if has_updated_at

      cols = row.keys.join(", ")
      vals = row.values.map { |v| connection.quote(v) }.join(", ")

      updates = row.keys.map do |k|
        "#{k} = EXCLUDED.#{k}"
      end.join(", ")

      sql = <<~SQL.squish
        INSERT INTO #{table_name} (#{cols})
        VALUES (#{vals})
        ON CONFLICT (id) DO UPDATE SET #{updates}
      SQL

      execute sql
    end
  end
end
