# frozen_string_literal: true

class AddIdFormatConstraintsToOccurrenceTables < ActiveRecord::Migration[8.2]
  def up
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute(<<~SQL.squish)
          ALTER TABLE #{table_name}
          ADD CONSTRAINT #{table_name}_id_format_check
          CHECK (id::text ~ '^[A-Z0-9_]+$')
        SQL
      end
    end
  end

  def down
    tables_to_constrain.each do |table_name|
      safety_assured do
        execute(<<~SQL.squish)
          ALTER TABLE #{table_name}
          DROP CONSTRAINT IF EXISTS #{table_name}_id_format_check
        SQL
      end
    end
  end

  private

  def tables_to_constrain
    %w(
      staff_occurrence_statuses
      user_occurrence_statuses
      zip_occurrence_statuses
      telephone_occurrence_statuses
      ip_occurrence_statuses
      email_occurrence_statuses
      domain_occurrence_statuses
      area_occurrence_statuses
    )
  end
end
