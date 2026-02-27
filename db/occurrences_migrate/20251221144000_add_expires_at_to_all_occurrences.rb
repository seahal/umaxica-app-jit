# frozen_string_literal: true

class AddExpiresAtToAllOccurrences < ActiveRecord::Migration[8.2]
  TABLES = %i(
    area_occurrences
    domain_occurrences
    email_occurrences
    ip_occurrences
    telephone_occurrences
    user_occurrences
  ).freeze

  def change
    TABLES.each do |table|
      add_column table, :expires_at, :datetime, null: false,
                                                default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }
      add_index table, :expires_at
    end
  end
end
