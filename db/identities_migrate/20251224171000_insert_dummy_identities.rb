class InsertDummyIdentities < ActiveRecord::Migration[8.2]
  def change
    # Insert Statuses first
    up_only do
      execute("INSERT INTO user_identity_statuses (id) VALUES ('NONE') ON CONFLICT DO NOTHING")
      execute("INSERT INTO staff_identity_statuses (id) VALUES ('NONE') ON CONFLICT DO NOTHING")
      execute("INSERT INTO staff_identity_audit_levels (id, created_at, updated_at) VALUES ('NONE', NOW(), NOW()) ON CONFLICT DO NOTHING")
      execute("INSERT INTO user_identity_audit_levels (id, created_at, updated_at) VALUES ('NONE', NOW(), NOW()) ON CONFLICT DO NOTHING")
      execute("INSERT INTO staff_identity_audit_events (id) VALUES ('NONE') ON CONFLICT DO NOTHING")
      execute("INSERT INTO user_identity_audit_events (id) VALUES ('NONE') ON CONFLICT DO NOTHING")

      # Dummy User and Staff
      # public_id required NOT NULL default ""
      execute("INSERT INTO users (id, public_id, user_identity_status_id, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', '000000000000000000000', 'NONE', NOW(), NOW()) ON CONFLICT DO NOTHING")
      execute("INSERT INTO staffs (id, public_id, staff_identity_status_id, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', '000000000000000000000', 'NONE', NOW(), NOW()) ON CONFLICT DO NOTHING")

      # Dummy Workspace
      execute("INSERT INTO workspaces (id, name, domain, parent_organization, created_at, updated_at) VALUES ('00000000-0000-0000-0000-000000000000', 'Dummy Workspace', 'dummy.local', '00000000-0000-0000-0000-000000000000', NOW(), NOW()) ON CONFLICT DO NOTHING")
    end
  end
end
