class CreateUserIdentityGoogleAuthStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :user_identity_google_auth_statuses, id: :string, limit: 255, primary_key: :id do |t|
      t.timestamps
    end

    # Insert default status records
    execute <<~SQL.squish
      INSERT INTO user_identity_google_auth_statuses (id, created_at, updated_at) VALUES
      ('ACTIVE', NOW(), NOW()),
      ('REVOKED', NOW(), NOW()),
      ('DELETED', NOW(), NOW())
      ON CONFLICT (id) DO NOTHING
    SQL
  end

  def down
    drop_table :user_identity_google_auth_statuses
  end
end
