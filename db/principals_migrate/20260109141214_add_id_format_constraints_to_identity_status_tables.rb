# frozen_string_literal: true

class AddIdFormatConstraintsToIdentityStatusTables < ActiveRecord::Migration[8.2]
  def up
    tables.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables.each do |table_name|
      safety_assured do
        execute <<~SQL.squish
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables
    %w(
      user_telephone_statuses
      user_statuses
      user_social_google_statuses
      user_social_apple_statuses
      user_secret_statuses
      user_passkey_statuses
      user_one_time_password_statuses
      user_email_statuses
      client_statuses
    )
  end
end
