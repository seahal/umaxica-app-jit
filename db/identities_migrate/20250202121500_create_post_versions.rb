# frozen_string_literal: true

class CreatePostVersions < ActiveRecord::Migration[8.2]
  def change
    create_table :post_versions, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :post_id, null: false
      t.string :permalink, limit: 200, null: false
      t.string :response_mode, null: false
      t.string :redirect_url
      t.string :title
      t.string :description
      t.text :body
      t.datetime :published_at, null: false
      t.datetime :expires_at, null: false
      t.string :edited_by_type
      t.string :edited_by_id
      t.string :public_id, null: false, default: ""

      t.timestamps
    end

    add_index :post_versions, %i(post_id created_at), order: { created_at: :desc }
    add_index :post_versions, :public_id, unique: true
  end
end
