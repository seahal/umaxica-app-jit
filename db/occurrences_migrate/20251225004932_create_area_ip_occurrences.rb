# frozen_string_literal: true

class CreateAreaIpOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :area_ip_occurrences do |t|
      t.references :area_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :ip_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
