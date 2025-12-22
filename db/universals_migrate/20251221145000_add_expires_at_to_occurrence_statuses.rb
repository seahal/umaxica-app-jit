class AddExpiresAtToOccurrenceStatuses < ActiveRecord::Migration[8.2]
  TABLES = %i[
    area_occurrence_statuses
    domain_occurrence_statuses
    email_occurrence_statuses
    ip_occurrence_statuses
    staff_occurrence_statuses
    telephone_occurrence_statuses
    user_occurrence_statuses
    zip_occurrence_statuses
  ].freeze

  def change
    TABLES.each do |table|
      add_column table, :expires_at, :datetime, null: false,
                                                default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }
      add_index table, :expires_at
    end
  end
end
