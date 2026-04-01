# frozen_string_literal: true

class CreateAreaZipOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table(:area_zip_occurrences) do |t|
      t.references(:area_occurrence, null: false, foreign_key: true, type: :bigint)
      t.references(:zip_occurrence, null: false, foreign_key: true, type: :bigint)

      t.timestamps
    end
  end
end
