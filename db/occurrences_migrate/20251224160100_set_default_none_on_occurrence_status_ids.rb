# frozen_string_literal: true

class SetDefaultNoneOnOccurrenceStatusIds < ActiveRecord::Migration[8.2]
  TABLES = %i[
    area_occurrences
    domain_occurrences
    email_occurrences
    ip_occurrences
    telephone_occurrences
  ].freeze

  def up
    TABLES.each do |table|
      safety_assured { execute("UPDATE #{table} SET status_id = 'NONE' WHERE status_id IS NULL") }
      safety_assured { change_column_default(table, :status_id, from: nil, to: "NONE") }
    end
  end

  def down
    TABLES.each do |table|
      safety_assured { change_column_default(table, :status_id, from: "NONE", to: nil) }
    end
  end
end
