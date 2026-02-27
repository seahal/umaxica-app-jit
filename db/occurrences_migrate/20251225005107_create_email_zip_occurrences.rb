# frozen_string_literal: true

class CreateEmailZipOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :email_zip_occurrences do |t|
      t.references :email_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :zip_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
