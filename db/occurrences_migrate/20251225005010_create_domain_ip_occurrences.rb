# frozen_string_literal: true

class CreateDomainIpOccurrences < ActiveRecord::Migration[8.2]
  def change
    create_table(:domain_ip_occurrences) do |t|
      t.references(:domain_occurrence, null: false, foreign_key: true, type: :bigint)
      t.references(:ip_occurrence, null: false, foreign_key: true, type: :bigint)

      t.timestamps
    end
  end
end
