class AddPublicIdToContactTopics < ActiveRecord::Migration[8.2]
  TABLES = %i(app_contact_topics com_contact_topics org_contact_topics).freeze

  def up
    TABLES.each do |table|
      add_column table, :public_id, :string, limit: 21
      add_index table, :public_id
    end

    TABLES.each { |table| backfill_public_ids(table) }

    TABLES.each do |table|
      change_column_null table, :public_id, false
    end
  end

  def down
    TABLES.each do |table|
      remove_index table, :public_id
      remove_column table, :public_id
    end
  end

  private

  def backfill_public_ids(table)
    say_with_time "Backfilling public_id for #{table}" do
      execute <<~SQL.squish
        UPDATE #{table}
        SET public_id = SUBSTR(REPLACE(gen_random_uuid()::text, '-', ''), 1, 21)
        WHERE public_id IS NULL
      SQL
    end
  end
end
