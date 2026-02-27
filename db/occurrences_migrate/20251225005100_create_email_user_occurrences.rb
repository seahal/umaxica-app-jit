# frozen_string_literal: true

class CreateEmailUserOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table :email_user_occurrences do |t|
      t.references :email_occurrence, null: false, foreign_key: true, type: :bigint
      t.references :user_occurrence, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
  end
end
