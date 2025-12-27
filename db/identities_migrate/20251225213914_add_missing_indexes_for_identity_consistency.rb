# frozen_string_literal: true

class AddMissingIndexesForIdentityConsistency < ActiveRecord::Migration[7.1]
  def up
    add_index :accounts, %i(accountable_type accountable_id), unique: true, if_not_exists: true
    add_index :user_identity_audits, :subject_id, if_not_exists: true
    add_index :staff_identity_audits, :subject_id, if_not_exists: true
    add_index :avatar_role_permissions, :avatar_permission_id, if_not_exists: true
    remove_index :avatar_memberships, name: :index_avatar_memberships_on_avatar_id, if_exists: true
  end

  def down
    add_index :avatar_memberships, :avatar_id, name: :index_avatar_memberships_on_avatar_id, if_not_exists: true
  end
end
