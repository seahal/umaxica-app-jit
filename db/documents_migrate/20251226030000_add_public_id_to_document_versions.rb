# frozen_string_literal: true

class AddPublicIdToDocumentVersions < ActiveRecord::Migration[8.2]
  def up
    # Add public_id to com_document_versions
    change_table :com_document_versions, bulk: true do |t|
      t.string :public_id, limit: 255, default: "", null: false
    end
    add_index :com_document_versions, :public_id, unique: true

    # Add public_id to app_document_versions
    change_table :app_document_versions, bulk: true do |t|
      t.string :public_id, limit: 255, default: "", null: false
    end
    add_index :app_document_versions, :public_id, unique: true

    # Add public_id to org_document_versions
    change_table :org_document_versions, bulk: true do |t|
      t.string :public_id, limit: 255, default: "", null: false
    end
    add_index :org_document_versions, :public_id, unique: true
  end

  def down
    # Remove from org_document_versions
    remove_index :org_document_versions, :public_id
    change_table :org_document_versions, bulk: true do |t|
      t.remove :public_id
    end

    # Remove from app_document_versions
    remove_index :app_document_versions, :public_id
    change_table :app_document_versions, bulk: true do |t|
      t.remove :public_id
    end

    # Remove from com_document_versions
    remove_index :com_document_versions, :public_id
    change_table :com_document_versions, bulk: true do |t|
      t.remove :public_id
    end
  end
end
