# frozen_string_literal: true

class CreateUserIdentityAuditEvents < ActiveRecord::Migration[8.2]
  def up
    create_table(:user_identity_audit_events, id: :string, limit: 255)

    safety_assured do
      execute("ALTER TABLE user_identity_audit_events ALTER COLUMN id SET DEFAULT 'NONE'")
    end
  end

  def down
    drop_table(:user_identity_audit_events)
  end
end
