# frozen_string_literal: true

class CreateIpStaffOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :ip_staff_occurrences do |t|
      t.references :ip_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :staff_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
