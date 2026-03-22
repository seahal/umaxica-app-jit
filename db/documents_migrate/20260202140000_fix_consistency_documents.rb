# frozen_string_literal: true

class FixConsistencyDocuments < ActiveRecord::Migration[8.2]
  def up
    safety_assured do
      tables = %w(
        org_documents org_document_revisions org_document_versions org_document_tags org_document_categories
        org_document_category_masters org_document_tag_masters org_document_statuses
        com_documents com_document_revisions com_document_versions com_document_tags com_document_categories
        com_document_category_masters com_document_tag_masters com_document_statuses
        app_documents app_document_revisions app_document_versions app_document_tags app_document_categories
        app_document_category_masters app_document_tag_masters app_document_statuses
      )
      existing = tables.select { |t| table_exists?(t) }
      execute("TRUNCATE TABLE #{existing.join(", ")} CASCADE") if existing.any?

      # --- OrgDocument ---
      # Fix revisions cascade
      if foreign_key_exists?(:org_document_revisions, :org_documents)
        remove_foreign_key(:org_document_revisions, :org_documents)
      end
      add_foreign_key(:org_document_revisions, :org_documents, on_delete: :cascade)

      # Fix tags index
      add_index(:org_document_tags, :org_document_id) unless index_exists?(:org_document_tags, :org_document_id)

      # Fix status_id type and FK
      change_column(:org_documents, :status_id, :bigint)
      add_foreign_key(:org_documents, :org_document_statuses, column: :status_id)

      # Fix CategoryMaster parent + Link from Category
      add_reference(
        :org_document_category_masters, :parent, foreign_key: { to_table: :org_document_category_masters },
                                                 index: true, null: true,
      )
      change_column(:org_document_categories, :org_document_category_master_id, :bigint)
      add_foreign_key(:org_document_categories, :org_document_category_masters)

      # Fix TagMaster parent + Link from Tag
      add_reference(
        :org_document_tag_masters, :parent, foreign_key: { to_table: :org_document_tag_masters },
                                            index: true, null: true,
      )
      change_column(:org_document_tags, :org_document_tag_master_id, :bigint)
      add_foreign_key(:org_document_tags, :org_document_tag_masters)

      # --- ComDocument ---
      if foreign_key_exists?(:com_document_revisions, :com_documents)
        remove_foreign_key(:com_document_revisions, :com_documents)
      end
      add_foreign_key(:com_document_revisions, :com_documents, on_delete: :cascade)
      add_index(:com_document_tags, :com_document_id) unless index_exists?(:com_document_tags, :com_document_id)
      change_column(:com_documents, :status_id, :bigint)
      add_foreign_key(:com_documents, :com_document_statuses, column: :status_id)

      add_reference(
        :com_document_category_masters, :parent, foreign_key: { to_table: :com_document_category_masters },
                                                 index: true, null: true,
      )
      change_column(:com_document_categories, :com_document_category_master_id, :bigint)
      add_foreign_key(:com_document_categories, :com_document_category_masters)

      add_reference(
        :com_document_tag_masters, :parent, foreign_key: { to_table: :com_document_tag_masters },
                                            index: true, null: true,
      )
      change_column(:com_document_tags, :com_document_tag_master_id, :bigint)
      add_foreign_key(:com_document_tags, :com_document_tag_masters)

      # --- AppDocument ---
      if foreign_key_exists?(:app_document_revisions, :app_documents)
        remove_foreign_key(:app_document_revisions, :app_documents)
      end
      add_foreign_key(:app_document_revisions, :app_documents, on_delete: :cascade)
      add_index(:app_document_tags, :app_document_id) unless index_exists?(:app_document_tags, :app_document_id)
      change_column(:app_documents, :status_id, :bigint)
      add_foreign_key(:app_documents, :app_document_statuses, column: :status_id)

      add_reference(
        :app_document_category_masters, :parent, foreign_key: { to_table: :app_document_category_masters },
                                                 index: true, null: true,
      )
      change_column(:app_document_categories, :app_document_category_master_id, :bigint)
      add_foreign_key(:app_document_categories, :app_document_category_masters)

      add_reference(
        :app_document_tag_masters, :parent, foreign_key: { to_table: :app_document_tag_masters },
                                            index: true, null: true,
      )
      change_column(:app_document_tags, :app_document_tag_master_id, :bigint)
      add_foreign_key(:app_document_tags, :app_document_tag_masters)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
