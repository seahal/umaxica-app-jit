# frozen_string_literal: true

class CreateStaffZipOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_zip_occurrences do |t|
      t.references :staff_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :zip_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
