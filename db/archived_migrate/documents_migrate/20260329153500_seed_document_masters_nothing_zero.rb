# frozen_string_literal: true

class SeedDocumentMastersNothingZero < ActiveRecord::Migration[8.2]
  def up
    tables = %i[
      app_document_category_masters
      app_document_tag_masters
      com_document_category_masters
      com_document_tag_masters
    ]

    safety_assured do
      tables.each do |table|
        next unless table_exists?(table)

        execute(<<~SQL.squish)
          INSERT INTO #{table} (id, parent_id)
          VALUES (0, 0)
          ON CONFLICT (id) DO NOTHING
        SQL
      end
    end
  end

  def down
    # Keep shared reference data in place once introduced.
  end
end
