# frozen_string_literal: true

class CreateAreaUserOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :area_user_occurrences, id: :uuid do |t|
      t.references :area_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :user_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
