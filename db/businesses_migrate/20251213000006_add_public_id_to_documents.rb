class AddPublicIdToDocuments < ActiveRecord::Migration[8.2]
  def up
    add_column :app_documents, :public_id, :string, limit: 21
    add_column :org_documents, :public_id, :string, limit: 21
    add_column :com_documents, :public_id, :string, limit: 21

    add_index :app_documents, :public_id
    add_index :org_documents, :public_id
    add_index :com_documents, :public_id

    say_with_time "Backfilling public_id for app_documents" do
      execute <<~SQL.squish
        UPDATE app_documents
        SET public_id = SUBSTR(REPLACE(gen_random_uuid()::text, '-', ''), 1, 21)
        WHERE public_id IS NULL
      SQL
    end

    say_with_time "Backfilling public_id for org_documents" do
      execute <<~SQL.squish
        UPDATE org_documents
        SET public_id = SUBSTR(REPLACE(gen_random_uuid()::text, '-', ''), 1, 21)
        WHERE public_id IS NULL
      SQL
    end

    say_with_time "Backfilling public_id for com_documents" do
      execute <<~SQL.squish
        UPDATE com_documents
        SET public_id = SUBSTR(REPLACE(gen_random_uuid()::text, '-', ''), 1, 21)
        WHERE public_id IS NULL
      SQL
    end

    change_column_null :app_documents, :public_id, false
    change_column_null :org_documents, :public_id, false
    change_column_null :com_documents, :public_id, false
  end

  def down
    remove_index :app_documents, :public_id
    remove_index :org_documents, :public_id
    remove_index :com_documents, :public_id

    remove_column :app_documents, :public_id
    remove_column :org_documents, :public_id
    remove_column :com_documents, :public_id
  end
end
