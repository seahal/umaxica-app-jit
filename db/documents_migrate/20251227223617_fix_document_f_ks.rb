# frozen_string_literal: true

class FixDocumentFKs < ActiveRecord::Migration[8.2]
  def change
    %i(org com app).each do |prefix|
      # Tag Master Parent FK
      # Checker: OrgDocumentTagMaster parent should have foreign key
      remove_foreign_key "#{prefix}_document_tag_masters", "#{prefix}_document_tag_masters", column: :parent_id, if_exists: true
      add_foreign_key "#{prefix}_document_tag_masters", "#{prefix}_document_tag_masters", column: :parent_id, validate: false

      # Category Master Parent FK
      # Checker: OrgDocumentCategoryMaster parent should have foreign key
      remove_foreign_key "#{prefix}_document_category_masters", "#{prefix}_document_category_masters", column: :parent_id, if_exists: true
      add_foreign_key "#{prefix}_document_category_masters", "#{prefix}_document_category_masters", column: :parent_id, validate: false

      # Status FK
      # Checker: OrgDocument org_document_status should have foreign key
      remove_foreign_key "#{prefix}_documents", "#{prefix}_document_statuses", column: :status_id, if_exists: true
      add_foreign_key "#{prefix}_documents", "#{prefix}_document_statuses", column: :status_id, validate: false

      # Cascades
      # Checker: OrgDocument org_document_versions should have foreign key with on_delete: :cascade
      remove_foreign_key "#{prefix}_document_versions", "#{prefix}_documents", if_exists: true
      add_foreign_key "#{prefix}_document_versions", "#{prefix}_documents", on_delete: :cascade, validate: false

      # Checker: OrgDocument org_document_tags should have foreign key with on_delete: :cascade
      remove_foreign_key "#{prefix}_document_tags", "#{prefix}_documents", if_exists: true
      add_foreign_key "#{prefix}_document_tags", "#{prefix}_documents", on_delete: :cascade, validate: false

      # Checker: OrgDocument category should have foreign key with on_delete: :cascade
      remove_foreign_key "#{prefix}_document_categories", "#{prefix}_documents", if_exists: true
      add_foreign_key "#{prefix}_document_categories", "#{prefix}_documents", on_delete: :cascade, validate: false
    end
  end
end
