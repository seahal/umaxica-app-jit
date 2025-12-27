# frozen_string_literal: true

class CreateComDocumentTagMasters < ActiveRecord::Migration[8.2]
  def change
    create_table :com_document_tag_masters, id: :string, limit: 255 do |t|
      t.string :parent_id, null: false, default: "none", limit: 255

      t.timestamps
    end

    add_index :com_document_tag_masters, :parent_id
  end
end
