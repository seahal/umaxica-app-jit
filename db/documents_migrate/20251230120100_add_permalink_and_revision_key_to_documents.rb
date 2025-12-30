# frozen_string_literal: true

class AddPermalinkAndRevisionKeyToDocuments < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      %i(app_documents com_documents org_documents).each do |table_name|
        add_permalink_and_revision(table_name)
      end
    end
  end

  def down
    safety_assured do
      %i(app_documents com_documents org_documents).each do |table_name|
        remove_index table_name, :permalink if table_exists?(table_name) && index_exists?(table_name, :permalink)
        remove_column table_name, :permalink if table_exists?(table_name) && column_exists?(table_name, :permalink)
        remove_column table_name, :revision_key if table_exists?(table_name) && column_exists?(table_name, :revision_key)
      end
    end
  end

  private

  def add_permalink_and_revision(table_name)
    return unless table_exists?(table_name)

    add_column table_name, :permalink, :string, limit: 200, null: false, default: "" unless column_exists?(table_name, :permalink)
    add_column table_name, :revision_key, :string, null: false, default: "" unless column_exists?(table_name, :revision_key)

    execute <<~SQL.squish
      UPDATE #{table_name}
      SET permalink = CASE
                        WHEN COALESCE(permalink, '') <> '' THEN permalink
                        WHEN COALESCE(public_id, '') <> '' THEN public_id
                        ELSE CONCAT('TMP_', md5(random()::text))
                      END,
          revision_key = CASE
                           WHEN COALESCE(revision_key, '') <> '' THEN revision_key
                           ELSE md5(random()::text)
                         END;
    SQL

    add_index table_name, :permalink, unique: true unless index_exists?(table_name, :permalink)
  end
end
