# frozen_string_literal: true

class CreateAreaEmailOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :area_email_occurrences do |t|
      t.references :area_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :email_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
