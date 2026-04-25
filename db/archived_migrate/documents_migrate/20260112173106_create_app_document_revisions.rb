# frozen_string_literal: true

class CreateAppDocumentRevisions < ActiveRecord::Migration[8.2]
  def change
    create_table(:app_document_revisions) do |t|
      t.references(:app_document, null: false, foreign_key: true, type: :bigint)
      t.string(:permalink, null: false, limit: 200)
      t.string(:response_mode, null: false)
      t.string(:redirect_url)
      t.string(:title)
      t.string(:description)
      t.text(:body)
      t.datetime(:published_at, null: false)
      t.datetime(:expires_at, null: false)
      t.string(:edited_by_type)
      t.bigint(:edited_by_id)
      t.string(:public_id, limit: 255, default: "", null: false)

      t.timestamps
    end

    add_index(:app_document_revisions, [:app_document_id, :created_at])
    add_index(:app_document_revisions, :public_id, unique: true)
  end
end
