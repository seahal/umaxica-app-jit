# frozen_string_literal: true

class RenameNoneToNeyoInIdentityReferenceData < ActiveRecord::Migration[8.2]
  def up
    rename_id_tables(
      %w(
        user_identity_statuses
        user_identity_email_statuses
        user_identity_telephone_statuses
        staff_identity_statuses
        user_identity_one_time_password_statuses
        user_identity_audit_events
        staff_identity_audit_events
        user_identity_audit_levels
        staff_identity_audit_levels
      ), from: "NONE", to: "NEYO",
    )

    update_fk(:users, :user_identity_status_id, from: "NONE", to: "NEYO")
    update_fk(:staffs, :staff_identity_status_id, from: "NONE", to: "NEYO")
    update_fk(:user_identity_emails, :user_identity_email_status_id, from: "NONE", to: "NEYO")
    update_fk(:user_identity_telephones, :user_identity_telephone_status_id, from: "NONE", to: "NEYO")
    update_fk(:user_identity_one_time_passwords, :user_identity_one_time_password_status_id, from: "NONE", to: "NEYO")
    update_fk(:user_identity_audits, :event_id, from: "NONE", to: "NEYO")
    update_fk(:staff_identity_audits, :event_id, from: "NONE", to: "NEYO")
    update_fk(:user_identity_audits, :level_id, from: "NONE", to: "NEYO")
    update_fk(:staff_identity_audits, :level_id, from: "NONE", to: "NEYO")

    change_column_default_if_exists(:users, :user_identity_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staffs, :staff_identity_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:user_identity_emails, :user_identity_email_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:user_identity_telephones, :user_identity_telephone_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:user_identity_one_time_passwords, :user_identity_one_time_password_status_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:user_identity_audits, :event_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_identity_audits, :event_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:user_identity_audits, :level_id, from: "NONE", to: "NEYO")
    change_column_default_if_exists(:staff_identity_audits, :level_id, from: "NONE", to: "NEYO")

    delete_id_tables(
      %w(
        user_identity_statuses
        user_identity_email_statuses
        user_identity_telephone_statuses
        staff_identity_statuses
        user_identity_one_time_password_statuses
        user_identity_audit_events
        staff_identity_audit_events
        user_identity_audit_levels
        staff_identity_audit_levels
      ), id: "NONE",
    )
  end

  def down
    rename_id_tables(
      %w(
        user_identity_statuses
        user_identity_email_statuses
        user_identity_telephone_statuses
        staff_identity_statuses
        user_identity_one_time_password_statuses
        user_identity_audit_events
        staff_identity_audit_events
        user_identity_audit_levels
        staff_identity_audit_levels
      ), from: "NEYO", to: "NONE",
    )

    update_fk(:users, :user_identity_status_id, from: "NEYO", to: "NONE")
    update_fk(:staffs, :staff_identity_status_id, from: "NEYO", to: "NONE")
    update_fk(:user_identity_emails, :user_identity_email_status_id, from: "NEYO", to: "NONE")
    update_fk(:user_identity_telephones, :user_identity_telephone_status_id, from: "NEYO", to: "NONE")
    update_fk(:user_identity_one_time_passwords, :user_identity_one_time_password_status_id, from: "NEYO", to: "NONE")
    update_fk(:user_identity_audits, :event_id, from: "NEYO", to: "NONE")
    update_fk(:staff_identity_audits, :event_id, from: "NEYO", to: "NONE")
    update_fk(:user_identity_audits, :level_id, from: "NEYO", to: "NONE")
    update_fk(:staff_identity_audits, :level_id, from: "NEYO", to: "NONE")

    change_column_default_if_exists(:users, :user_identity_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staffs, :staff_identity_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:user_identity_emails, :user_identity_email_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:user_identity_telephones, :user_identity_telephone_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:user_identity_one_time_passwords, :user_identity_one_time_password_status_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:user_identity_audits, :event_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_identity_audits, :event_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:user_identity_audits, :level_id, from: "NEYO", to: "NONE")
    change_column_default_if_exists(:staff_identity_audits, :level_id, from: "NEYO", to: "NONE")

    delete_id_tables(
      %w(
        user_identity_statuses
        user_identity_email_statuses
        user_identity_telephone_statuses
        staff_identity_statuses
        user_identity_one_time_password_statuses
        user_identity_audit_events
        staff_identity_audit_events
        user_identity_audit_levels
        staff_identity_audit_levels
      ), id: "NEYO",
    )
  end

  private

  def rename_id_tables(tables, from:, to:)
    tables.each do |table|
      rename_id(table, from: from, to: to)
    end
  end

  def rename_id(table, from:, to:)
    return unless table_exists?(table)

    has_timestamps = column_exists?(table, :created_at) && column_exists?(table, :updated_at)

    safety_assured do
      execute <<~SQL.squish
        INSERT INTO #{table} (id#{has_timestamps ? ", created_at, updated_at" : ""})
        VALUES ('#{to}'#{has_timestamps ? ", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP" : ""})
        ON CONFLICT (id) DO NOTHING
      SQL
    end

    change_column_default_if_exists(table, :id, from: from, to: to)
  end

  def insert_sql(table, id, has_timestamps)
    if has_timestamps
      "INSERT INTO #{table} (id, created_at, updated_at) VALUES ('#{id}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);"
    else
      "INSERT INTO #{table} (id) VALUES ('#{id}');"
    end
  end

  def update_fk(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    safety_assured do
      execute <<~SQL.squish
        UPDATE #{table}
        SET #{column} = '#{to}'
        WHERE #{column} = '#{from}'
      SQL
    end
  end

  def change_column_default_if_exists(table, column, from:, to:)
    return unless table_exists?(table) && column_exists?(table, column)

    change_column_default table, column, from: from, to: to
  end

  def delete_id_tables(tables, id:)
    tables.each do |table|
      delete_id(table, id)
    end
  end

  def delete_id(table, id)
    return unless table_exists?(table)

    safety_assured do
      execute <<~SQL.squish
        DELETE FROM #{table}
        WHERE id = '#{id}'
      SQL
    end
  end
end
