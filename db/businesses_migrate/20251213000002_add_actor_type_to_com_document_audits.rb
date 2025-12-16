class AddActorTypeToComDocumentAudits < ActiveRecord::Migration[8.2]
  def change
    add_column :com_document_audits, :actor_type, :string
  end
end
