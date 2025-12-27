# frozen_string_literal: true

class AddExpiresAtToZipAndStaffOccurrences < ActiveRecord::Migration[8.2]
  def change
    add_column :zip_occurrences, :expires_at, :datetime, null: false,
                                                         default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }
    add_column :staff_occurrences, :expires_at, :datetime, null: false,
                                                           default: -> { "(CURRENT_TIMESTAMP + 'P7Y'::interval)" }

    add_index :zip_occurrences, :expires_at
    add_index :staff_occurrences, :expires_at
  end
end
