# frozen_string_literal: true

class CreateClientIdentityStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table :client_identity_statuses, id: :string, limit: 255 do |t|
      t.timestamps
    end

    safety_assured do
      execute "ALTER TABLE client_identity_statuses ALTER COLUMN id SET DEFAULT 'NEYO'"
      execute <<~SQL.squish
        INSERT INTO client_identity_statuses (id, created_at, updated_at)
        VALUES ('NEYO', NOW(), NOW())
        ON CONFLICT (id) DO NOTHING
      SQL
    end
  end

  def down
    drop_table :client_identity_statuses
  end
end
