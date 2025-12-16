class CreateTokenStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table :user_token_statuses, id: { type: :string, limit: 255, default: "NONE" } do |t|
      t.timestamps
    end

    create_table :staff_token_statuses, id: { type: :string, limit: 255, default: "NONE" } do |t|
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute "INSERT INTO user_token_statuses (id, created_at, updated_at) VALUES ('NONE', NOW(), NOW())"
        execute "INSERT INTO staff_token_statuses (id, created_at, updated_at) VALUES ('NONE', NOW(), NOW())"
      end
    end

    add_column :user_tokens, :user_token_status_id, :string, default: "NONE", null: false
    add_column :staff_tokens, :staff_token_status_id, :string, default: "NONE", null: false

    add_foreign_key :user_tokens, :user_token_statuses
    add_foreign_key :staff_tokens, :staff_token_statuses
  end
end
