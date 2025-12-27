# frozen_string_literal: true

class CreateTelephoneZipOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :telephone_zip_occurrences, id: :uuid do |t|
      t.references :telephone_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :zip_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
