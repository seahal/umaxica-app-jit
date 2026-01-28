# frozen_string_literal: true

class AddUniqueIndexesForDocumentMasterIds < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_index :org_document_tag_masters, "lower(id)", unique: true, name: "index_org_document_tag_masters_on_lower_id",
                                                      algorithm: :concurrently
    add_index :com_document_tag_masters, "lower(id)", unique: true, name: "index_com_document_tag_masters_on_lower_id",
                                                      algorithm: :concurrently
    add_index :app_document_tag_masters, "lower(id)", unique: true, name: "index_app_document_tag_masters_on_lower_id",
                                                      algorithm: :concurrently

    add_index :org_document_category_masters, "lower(id)", unique: true,
                                                           name: "index_org_document_category_masters_on_lower_id",
                                                           algorithm: :concurrently
    add_index :com_document_category_masters, "lower(id)", unique: true,
                                                           name: "index_com_document_category_masters_on_lower_id",
                                                           algorithm: :concurrently
    add_index :app_document_category_masters, "lower(id)", unique: true,
                                                           name: "index_app_document_category_masters_on_lower_id",
                                                           algorithm: :concurrently
  end
end
