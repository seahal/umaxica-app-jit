# frozen_string_literal: true

class FixContactDomainModelsFinal < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      # 1. Categories and Statuses (Reference Tables)
      %w(
        app_contact_categories app_contact_statuses
        com_contact_categories com_contact_statuses
        org_contact_categories org_contact_statuses
      ).each do |table|
        remove_column table, :code if column_exists?(table, :code)
      end

      # Universal Statuses
      contact_statuses = {
        1 => "NEYO",
        2 => "CHECKED_EMAIL_ADDRESS",
        3 => "EMAIL_PENDING",
        4 => "PHONE_VERIFIED",
        5 => "COMPLETED",
        6 => "EMAIL_VERIFIED",
        7 => "SET_UP",
        8 => "NULL_COM_STATUS",
        9 => "CHECKED_TELEPHONE_NUMBER",
        10 => "COMPLETED_CONTACT_ACTION",
      }

      %w(app_contact_statuses com_contact_statuses org_contact_statuses).each do |table|
        execute "TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE"
        contact_statuses.each do |id, _code|
          execute "INSERT INTO #{table} (id) VALUES (#{id})"
        end
        execute "SELECT setval(pg_get_serial_sequence('#{table}', 'id'), #{contact_statuses.keys.max})"
      end

      # Specific Categories
      categories = {
        app_contact_categories: { 1 => "NEYO", 2 => "APPLICATION_INQUIRY" },
        com_contact_categories: { 1 => "NEYO", 2 => "SECURITY_ISSUE" },
        org_contact_categories: { 1 => "NEYO", 2 => "ORGANIZATION_INQUIRY" },
      }

      categories.each do |table, mapping|
        execute "TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE"
        mapping.each do |id, _code|
          execute "INSERT INTO #{table} (id) VALUES (#{id})"
        end
        execute "SELECT setval(pg_get_serial_sequence('#{table}', 'id'), #{mapping.keys.max})"
      end

      # Helper for adding columns missing in a table
      add_missing_column =
        ->(table, col, type, options = {}) {
          add_column table, col, type, **options unless column_exists?(table, col)
        }

      # 2. Emails and Telephones
      %i(com_contact_emails app_contact_emails org_contact_emails).each do |table|
        t_name = table.to_s
        remove_column t_name, :code if column_exists?(t_name, :code)

        add_missing_column.call(t_name, :email_address, :string, limit: 1000, null: false, default: "")
        add_missing_column.call(t_name, :activated, :boolean, null: false, default: false)
        add_missing_column.call(t_name, :verifier_digest, :string, limit: 255)
        add_missing_column.call(t_name, :verifier_expires_at, :timestamptz)
        add_missing_column.call(t_name, :verifier_attempts_left, :integer, limit: 2, default: 3, null: false)
        add_missing_column.call(t_name, :token_digest, :string, limit: 255)
        add_missing_column.call(t_name, :token_expires_at, :timestamptz)
        add_missing_column.call(t_name, :token_viewed, :boolean, default: false, null: false)
        add_missing_column.call(t_name, :created_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" })
        add_missing_column.call(t_name, :updated_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" })

        if table == :com_contact_emails
          add_missing_column.call(t_name, :deletable, :boolean, null: false, default: false)
          add_missing_column.call(t_name, :remaining_views, :integer, limit: 2, default: 10, null: false)
          add_missing_column.call(t_name, :expires_at, :timestamptz, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" })
          add_missing_column.call(t_name, :hotp_secret, :string)
          add_missing_column.call(t_name, :hotp_counter, :integer)
        end

        add_index table, :email_address unless index_exists?(table, :email_address)
      end

      %i(com_contact_telephones app_contact_telephones org_contact_telephones).each do |table|
        t_name = table.to_s
        remove_column t_name, :code if column_exists?(t_name, :code)

        add_missing_column.call(t_name, :telephone_number, :string, limit: 1000, null: false, default: "")
        add_missing_column.call(t_name, :activated, :boolean, null: false, default: false)
        add_missing_column.call(t_name, :verifier_digest, :string, limit: 255)
        add_missing_column.call(t_name, :verifier_expires_at, :timestamptz)
        add_missing_column.call(t_name, :verifier_attempts_left, :integer, limit: 2, default: 3, null: false)
        add_missing_column.call(t_name, :created_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" })
        add_missing_column.call(t_name, :updated_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" })

        if table == :com_contact_telephones
          add_missing_column.call(t_name, :deletable, :boolean, null: false, default: false)
          add_missing_column.call(t_name, :remaining_views, :integer, limit: 2, default: 10, null: false)
          add_missing_column.call(t_name, :expires_at, :timestamptz, null: false, default: -> { "CURRENT_TIMESTAMP + interval '1 day'" })
          add_missing_column.call(t_name, :hotp_secret, :string)
          add_missing_column.call(t_name, :hotp_counter, :integer)
        end
        add_index table, :telephone_number unless index_exists?(table, :telephone_number)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
