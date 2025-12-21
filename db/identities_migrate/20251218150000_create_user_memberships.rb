class CreateUserMemberships < ActiveRecord::Migration[8.2]
  def up
    create_table :user_memberships, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :workspace, null: false, foreign_key: { to_table: :organizations }, type: :uuid

      t.datetime :joined_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.datetime :left_at

      t.timestamps
    end

    add_index :user_memberships, %i[user_id workspace_id], unique: true

    execute <<~SQL.squish
      INSERT INTO user_memberships (id, user_id, workspace_id, joined_at, created_at, updated_at)
      SELECT uuidv7(), user_id, organization_id, created_at, created_at, updated_at
      FROM user_organizations
      ON CONFLICT (user_id, workspace_id) DO NOTHING
    SQL
  end

  def down
    drop_table :user_memberships
  end
end
