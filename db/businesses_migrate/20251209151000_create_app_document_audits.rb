class CreateAppDocumentAudits < ActiveRecord::Migration[8.2]
  def change
    create_table :app_document_audits, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :app_document, null: false, foreign_key: true, type: :uuid
      t.string :event_id, null: false, limit: 255
      t.datetime :timestamp
      t.string :ip_address
      t.uuid :actor_id
      t.text :previous_value
      t.text :current_value

      t.timestamps
    end
  end
end
