# frozen_string_literal: true

class CreateEmailTelephoneOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :email_telephone_occurrences do |t|
      t.references :email_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :telephone_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
