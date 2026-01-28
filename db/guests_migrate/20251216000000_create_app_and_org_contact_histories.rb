# frozen_string_literal: true

class CreateAppAndOrgContactHistories < ActiveRecord::Migration[8.2]
  def change
    create_table :app_contact_histories, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :app_contact, null: false, foreign_key: true, type: :uuid
      t.uuid :parent_id, null: true
      t.integer :position, null: false, default: 0
      t.uuid :actor_id
      t.string :actor_type
      t.timestamps
    end

    create_table :org_contact_histories, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :org_contact, null: false, foreign_key: true, type: :uuid
      t.uuid :parent_id, null: true
      t.integer :position, null: false, default: 0
      t.uuid :actor_id
      t.string :actor_type
      t.timestamps
    end
  end
end
