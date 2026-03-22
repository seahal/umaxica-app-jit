# frozen_string_literal: true

class CreateDomainUserOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table(:domain_user_occurrences) do |t|
      t.references(:domain_occurrence, null: false, foreign_key: true, type: :bigint)
      t.references(:user_occurrence, null: false, foreign_key: true, type: :bigint)

      t.timestamps
    end
  end
end
