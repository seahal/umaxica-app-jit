# frozen_string_literal: true

class AddPublicIdToContactTopics < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  TABLES = %i(app_contact_topics com_contact_topics org_contact_topics).freeze

  def up
    TABLES.each do |table|
      add_column(table, :public_id, :string, limit: 21)
      add_index(table, :public_id, algorithm: :concurrently)
    end

    TABLES.each { |table| backfill_public_ids(table) }

    TABLES.each do |table|
      add_check_constraint(
        table,
        "public_id IS NOT NULL",
        name: check_constraint_name_for(table),
        validate: false,
      )
    end
  end

  def down
    TABLES.each do |table|
      remove_index(table, :public_id, algorithm: :concurrently)
      remove_column(table, :public_id)
    end
  end

  private

  def backfill_public_ids(table)
    safety_assured do
      say_with_time("Backfilling public_id for #{table}") do
        execute(<<~SQL.squish)
          UPDATE #{table}
          SET public_id = ''
          WHERE public_id IS NULL
        SQL
      end
    end
  end

  def check_constraint_name_for(table)
    "#{table}_public_id_null"
  end
end
