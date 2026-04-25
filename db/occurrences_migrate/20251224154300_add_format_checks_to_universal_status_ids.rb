# frozen_string_literal: true

class AddFormatChecksToUniversalStatusIds < ActiveRecord::Migration[8.2]
  TABLES = %i[
    area_occurrence_statuses
    domain_occurrence_statuses
    email_occurrence_statuses
    ip_occurrence_statuses
    telephone_occurrence_statuses
  ].freeze

  def change
    TABLES.each do |table|
      safety_assured do
        add_check_constraint(table, "id IS NULL OR id ~ '^[A-Z0-9_]+$'", name: "chk_#{table}_id_format", validate: false)
      end
    end
  end
end
