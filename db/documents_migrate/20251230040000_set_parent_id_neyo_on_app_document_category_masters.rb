# frozen_string_literal: true

class SetParentIdNeyoOnAppDocumentCategoryMasters < ActiveRecord::Migration[8.2]
  def up
    return unless table_exists?(:app_document_category_masters)

    safety_assured do
      execute <<~SQL.squish
        UPDATE app_document_category_masters
        SET parent_id = 'NEYO'
        WHERE parent_id = 'none'
           OR parent_id IS NULL
      SQL
    end

    change_column_default :app_document_category_masters, :parent_id, from: "none", to: "NEYO"
    safety_assured do
      change_column_null :app_document_category_masters, :parent_id, false
    end
  end

  def down
    return unless table_exists?(:app_document_category_masters)

    safety_assured do
      execute <<~SQL.squish
        UPDATE app_document_category_masters
        SET parent_id = 'none'
        WHERE parent_id = 'NEYO'
      SQL
    end

    change_column_default :app_document_category_masters, :parent_id, from: "NEYO", to: "none"
    change_column_null :app_document_category_masters, :parent_id, false
  end
end
