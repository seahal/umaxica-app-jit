# frozen_string_literal: true

class CreateStaffTelephoneOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :staff_telephone_occurrences, id: :uuid do |t|
      t.references :staff_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :telephone_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
