# frozen_string_literal: true

class RenameOrgDocumentTagTables < ActiveRecord::Migration[8.2]
  def change
    # Rename org_document_tags to org_document_tag_masters
    rename_table :org_document_tags, :org_document_tag_masters

    # Rename org_document_taggers to org_document_tags
    rename_table :org_document_taggers, :org_document_tags

    # Update foreign key column name in the new org_document_tags table
    rename_column :org_document_tags, :org_document_tag_id, :org_document_tag_master_id
  end
end
