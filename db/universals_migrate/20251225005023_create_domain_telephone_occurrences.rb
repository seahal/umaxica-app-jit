# frozen_string_literal: true

class CreateDomainTelephoneOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :domain_telephone_occurrences, id: :uuid do |t|
      t.references :domain_occurrence, null: false, foreign_key: true, type: :uuid
      t.references :telephone_occurrence, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
