# frozen_string_literal: true

# Migration to add latest_version_id and latest_revision_id columns to document tables
# This resolves ForeignKeyTypeChecker warnings for document associations
class AddLatestVersionAndRevisionToDocuments < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    # App Documents
    add_column :app_documents, :latest_version_id, :bigint
    add_column :app_documents, :latest_revision_id, :bigint

    add_foreign_key :app_documents, :app_document_versions,
                    column: :latest_version_id,
                    on_delete: :nullify,
                    validate: false
    add_foreign_key :app_documents, :app_document_revisions,
                    column: :latest_revision_id,
                    on_delete: :nullify,
                    validate: false

    add_index :app_documents, :latest_version_id,
              name: "index_app_documents_on_latest_version_id",
              unique: true,
              algorithm: :concurrently
    add_index :app_documents, :latest_revision_id,
              name: "index_app_documents_on_latest_revision_id",
              unique: true,
              algorithm: :concurrently

    # Com Documents
    add_column :com_documents, :latest_version_id, :bigint
    add_column :com_documents, :latest_revision_id, :bigint

    add_foreign_key :com_documents, :com_document_versions,
                    column: :latest_version_id,
                    on_delete: :nullify,
                    validate: false
    add_foreign_key :com_documents, :com_document_revisions,
                    column: :latest_revision_id,
                    on_delete: :nullify,
                    validate: false

    add_index :com_documents, :latest_version_id,
              name: "index_com_documents_on_latest_version_id",
              unique: true,
              algorithm: :concurrently
    add_index :com_documents, :latest_revision_id,
              name: "index_com_documents_on_latest_revision_id",
              unique: true,
              algorithm: :concurrently

    # Org Documents
    add_column :org_documents, :latest_version_id, :bigint
    add_column :org_documents, :latest_revision_id, :bigint

    add_foreign_key :org_documents, :org_document_versions,
                    column: :latest_version_id,
                    on_delete: :nullify,
                    validate: false
    add_foreign_key :org_documents, :org_document_revisions,
                    column: :latest_revision_id,
                    on_delete: :nullify,
                    validate: false

    add_index :org_documents, :latest_version_id,
              name: "index_org_documents_on_latest_version_id",
              unique: true,
              algorithm: :concurrently
    add_index :org_documents, :latest_revision_id,
              name: "index_org_documents_on_latest_revision_id",
              unique: true,
              algorithm: :concurrently
  end
end
