class AddActorTypeToOrgDocumentAudits < ActiveRecord::Migration[8.2]
  def change
    add_column :org_document_audits, :actor_type, :string
  end
end
